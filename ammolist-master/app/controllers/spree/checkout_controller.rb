module Spree
  # This is somewhat contrary to standard REST convention since there is not
  # actually a Checkout object. There's enough distinct logic specific to
  # checkout which has nothing to do with updating an order that this approach
  # is waranted.
  class CheckoutController < Spree::StoreController
    ssl_required

    before_action :load_order_with_lock, except: [:update_delivery, :update_shipment_upgrade]
    before_filter :ensure_valid_state_lock_version, only: [:update]
    before_filter :set_state_if_present, except: [:update_delivery, :update_shipment_upgrade]

    before_action :ensure_order_not_completed, except: [:update_delivery, :update_shipment_upgrade]
    before_action :ensure_checkout_allowed, except: [:update_delivery, :update_shipment_upgrade]
    before_action :ensure_sufficient_stock_lines, except: [:update_delivery, :update_shipment_upgrade]
    before_action :ensure_valid_state, except: [:update_delivery, :update_shipment_upgrade]

    before_action :associate_user, except: [:update_delivery, :update_shipment_upgrade]
    before_action :check_authorization, except: [:update_delivery, :update_shipment_upgrade]
    before_action :apply_coupon_code, except: [:update_delivery, :update_shipment_upgrade]

    before_action :setup_for_current_state, except: [:update_delivery, :update_shipment_upgrade]
    before_action :load_contact_information, except: [:update_delivery, :update_shipment_upgrade]

    helper 'spree/orders'

    rescue_from Spree::Core::GatewayError, :with => :rescue_from_spree_gateway_error

    # Updates the order and advances to the next state (when possible.)
    def update  
      if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
        @order.temporary_address = !params[:save_user_address]
        unless @order.next
          flash[:error] = @order.errors.full_messages.join("\n")
          redirect_to checkout_state_path(@order.state) and return
        end
        
        if @order.completed?
          @current_order = nil
          flash.notice = Spree.t(:order_processed_successfully)
          flash['order_completed'] = true
          redirect_to completion_route
        else
          if params[:form_origin].blank?
            redirect_to checkout_state_path(@order.state)
          else
            redirect_to checkout_state_path(@order.state, { :form_origin => params[:form_origin] })
          end
        end
      else
        render :edit
      end 
    end

    def update_delivery
      @shipment_id = params[:shipment_id]
      @ship_form_index = params[:shipment_form_id]
      @selected_shipping_rate_id = params[:selected_shipping_rate_id]

      @shipment = Spree::Shipment.find_by_id(@shipment_id)
      @shipment.selected_shipping_rate_id = @selected_shipping_rate_id
      @shipment.save

      @shipment.update_amounts

      @shipment.order.updater.update_shipment_total
      @shipment.order.updater.persist_totals
    end

    def update_shipment_upgrade
      @shipment = Spree::Shipment.find_by_id(params[:shipment_id])
      @shipment.shipment_upgrades.update(params[:selected_shipping_upgrade_id], selected: params[:selected_shipping_upgrade_status])
      @shipment.order.updater.update_shipment_total
      
      if  @shipment.order.updater.persist_totals
        response_msg = [ :status => 'success', :message => "Selected Shipping upgrade has been added." ]
      else
        response_msg = [ :status => 'error', :message => "Selected Shipping can not be added. Please try again later" ]
      end
      respond_to do |format|
        format.js { render :json => response_msg }
      end
    end

    private
      def ensure_valid_state
        unless skip_state_validation?
          if (params[:state] && !@order.has_checkout_step?(params[:state])) ||
             (!params[:state] && !@order.has_checkout_step?(@order.state))
            @order.state = 'cart'
            redirect_to checkout_state_path(@order.checkout_steps.first)
          end
        end

        # Fix for #4117
        # If confirmation of payment fails, redirect back to payment screen
        if params[:state] == "confirm" && @order.payment_required? && @order.payments.valid.empty?
          flash.keep
          redirect_to checkout_state_path("payment")
        end
      end

      # Should be overriden if you have areas of your checkout that don't match
      # up to a step within checkout_steps, such as a registration step
      def skip_state_validation?
        false
      end

      def load_order_with_lock
        @order = current_order(lock: true)
        redirect_to spree.cart_path and return unless @order
      end

      def ensure_valid_state_lock_version
        if params[:order] && params[:order][:state_lock_version]
          @order.with_lock do
            unless @order.state_lock_version == params[:order].delete(:state_lock_version).to_i
              flash[:error] = Spree.t(:order_already_updated)
              redirect_to checkout_state_path(@order.state) and return
            end
            @order.increment!(:state_lock_version)
          end
        end
      end

      def set_state_if_present
        if params[:state]
          redirect_to checkout_state_path(@order.state) if @order.can_go_to_state?(params[:state]) && !skip_state_validation?
          @order.state = params[:state]
        end
      end

      def ensure_checkout_allowed
        unless @order.checkout_allowed?
          redirect_to spree.cart_path
        end
      end

      def ensure_order_not_completed
        redirect_to spree.cart_path if @order.completed?
      end

      def ensure_sufficient_stock_lines
        if @order.insufficient_stock_lines.present?
          flash[:error] = Spree.t(:inventory_error_flash_for_insufficient_quantity)
          redirect_to spree.cart_path
        end
      end

      # Provides a route to redirect after order completion
      def completion_route
        spree.order_path(@order)
      end

      def setup_for_current_state
        method_name = :"before_#{@order.state}"
        send(method_name) if respond_to?(method_name, true)
      end

      def before_address
        # check if user is a guest, redirect to registration form
        if params[:form_origin].blank? && !@order.email?
          @order.state = 'cart'
          @order.save
          store_location
          redirect_to spree.checkout_registration_path
        end

        # if the user has a default address, a callback takes care of setting
        # that; but if he doesn't, we need to build an empty one here
        if params[:form_origin] == "cart"
          @order.bill_address ||= Address.build_default_require_data(false)
          @order.ship_address ||= Address.build_default_require_data(false) if @order.checkout_steps.include?('delivery')
        else
          @order.bill_address ||= Address.build_default
          @order.ship_address ||= Address.build_default if @order.checkout_steps.include?('delivery')
        end
      end

      def before_delivery
        return if params[:order].present?

        if params[:form_origin].blank? && !@order.email?
          @order.state = 'cart'
          @order.save
          store_location
          redirect_to spree.checkout_registration_path
        elsif params[:form_origin].blank? && (@order.bill_address.empty? || @order.ship_address.empty?)
          @order.state = 'address'
          @order.save
          redirect_to checkout_state_path(@order.state)       
        end

        packages = @order.shipments.map { |s| s.to_package }
        @differentiator = Spree::Stock::Differentiator.new(@order, packages)
      end

      def before_payment
        if @order.checkout_steps.include? "delivery"
          packages = @order.shipments.map { |s| s.to_package }
          @differentiator = Spree::Stock::Differentiator.new(@order, packages)
          @differentiator.missing.each do |variant, quantity|
            @order.contents.remove(variant, quantity)
          end
        end

        if try_spree_current_user && try_spree_current_user.respond_to?(:payment_sources)
          @payment_sources = try_spree_current_user.payment_sources
        end
      end

      def rescue_from_spree_gateway_error(exception)
        flash.now[:error] = Spree.t(:spree_gateway_error_flash_for_checkout)
        @order.errors.add(:base, exception.message)
        render :edit
      end

      def check_authorization
        authorize!(:edit, current_order, cookies.signed[:guest_token])
      end

      def load_contact_information
        site_id = Ammolist::Config[:cms_id]
        @site = Comfy::Cms::Site.find_by_id(site_id)
        # get properties layout id 8 "Spree Checkoutpage Embedded"
        @properties = @site.pages.published.where(:layout_id => 8)
      end
  end
end
