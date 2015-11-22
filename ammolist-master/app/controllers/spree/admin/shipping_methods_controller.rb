module Spree
  module Admin
    class ShippingMethodsController < ResourceController
      before_action :load_data, except: :index
      before_action :set_shipping_category, only: [:create, :update]
      before_action :set_zones, only: [:create, :update]
      before_action :set_constraints, only: [:create, :update]
      after_action :set_constraints_values, only: [:create, :update]
      before_action :set_shipping_upgrades, only: [:create, :update]
      after_action :set_shipping_method_upgrades, only: [:create, :update] 


      def destroy
        @object.destroy

        flash[:success] = flash_message_for(@object, :successfully_removed)

        respond_with(@object) do |format|
          format.html { redirect_to collection_url }
          format.js  { render_js_for_destroy }
        end
      end

      private

      @constraints_values = {}
      @shipping_upgrades_values = {}

      def set_shipping_category
        return true if params["shipping_method"][:shipping_categories] == ""
        @shipping_method.shipping_categories = Spree::ShippingCategory.where(:id => params["shipping_method"][:shipping_categories])
        @shipping_method.save
        params[:shipping_method].delete(:shipping_categories)
      end

      def set_zones
        return true if params["shipping_method"][:zones] == ""
        @shipping_method.zones = Spree::Zone.where(:id => params["shipping_method"][:zones])
        @shipping_method.save
        params[:shipping_method].delete(:zones)
      end

      def set_constraints
        Spree::ConstraintType.all.each do |constraint|
          @shipping_method.constraint_types = Spree::ConstraintType.where(:id => constraint.id)
          @shipping_method.save
        end
        @constraints_values = params["shipping_method"][:constraint_types]
        params[:shipping_method].delete(:constraint_types)
      end

      def set_constraints_values
        Spree::ConstraintType.all.each do |constraint|
          shipping_contraint = Spree::ShippingConstraint.where(shipping_method_id: @shipping_method.id, constraint_type_id: constraint.id)
          if !shipping_contraint.empty?
            shipping_contraint.first.min_value = @constraints_values[constraint.id.to_s][:shipping_constraints][:min_value]
            shipping_contraint.first.max_value = @constraints_values[constraint.id.to_s][:shipping_constraints][:max_value]
            shipping_contraint.first.save
          end
        end
      end

      def set_shipping_upgrades
        return true if params["shipping_method"][:shipping_upgrades] == ""
        shipping_upgrades_id = params["shipping_method"][:shipping_upgrades].map { |k,v| k }
        @shipping_method.shipping_upgrades = Spree::ShippingUpgrade.where(:id => shipping_upgrades_id)
        @shipping_method.save
        @shipping_upgrades_values = params["shipping_method"][:shipping_upgrades]
        params[:shipping_method].delete(:shipping_upgrades)
      end

      def set_shipping_method_upgrades
        @shipping_method.shipping_upgrades.each do |su|
          smu = @shipping_method.shipping_method_upgrades.find_by_shipping_upgrade_id(su.id)
          if smu
            smu.calculated_value = @shipping_upgrades_values[su.id.to_s]
            smu.save
          end
        end
      end

      def location_after_save
        edit_admin_shipping_method_path(@shipping_method)
      end

      def load_data
        @available_zones = Zone.order(:name)
        @tax_categories = Spree::TaxCategory.order(:name)
        @calculators = ShippingMethod.calculators.sort_by(&:name)
      end
    end
  end
end
