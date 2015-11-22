module Spree
  module Admin
    class ShippingConstraintsController < ResourceController
      before_action :set_shipping_constraint, only: [:show, :edit, :update, :destroy]

      # GET /shipping_constraints
      # GET /shipping_constraints.json
      def index
        @shipping_constraints = ShippingConstraint.all
      end

      # GET /shipping_constraints/1
      # GET /shipping_constraints/1.json
      def show
      end

      # GET /shipping_constraints/new
      def new
        @shipping_constraint = ShippingConstraint.new
        @constraint_types = ConstraintType.all
      end

      # GET /shipping_constraints/1/edit
      def edit
      end

      # POST /shipping_constraints
      # POST /shipping_constraints.json
      def create
        @shipping_constraint = ShippingConstraint.new(shipping_constraint_params)

        respond_to do |format|
          if @shipping_constraint.save
            format.html { redirect_to @shipping_constraint, notice: 'Shipping constraint was successfully created.' }
            format.json { render :show, status: :created, location: @shipping_constraint }
          else
            format.html { render :new }
            format.json { render json: @shipping_constraint.errors, status: :unprocessable_entity }
          end
        end
      end

      # PATCH/PUT /shipping_constraints/1
      # PATCH/PUT /shipping_constraints/1.json
      def update
        respond_to do |format|
          if @shipping_constraint.update(shipping_constraint_params)
            format.html { redirect_to @shipping_constraint, notice: 'Shipping constraint was successfully updated.' }
            format.json { render :show, status: :ok, location: @shipping_constraint }
          else
            format.html { render :edit }
            format.json { render json: @shipping_constraint.errors, status: :unprocessable_entity }
          end
        end
      end

      # DELETE /shipping_constraints/1
      # DELETE /shipping_constraints/1.json
      def destroy
        @shipping_constraint.destroy
        respond_to do |format|
          format.html { redirect_to shipping_constraints_url, notice: 'Shipping constraint was successfully destroyed.' }
          format.json { head :no_content }
        end
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_shipping_constraint
          @shipping_constraint = ShippingConstraint.find(params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def shipping_constraint_params
          params.require(:shipping_constraint).permit(:shipping_method_id, :constraint_type_id, :min_value, :max_value)
        end
    end
  end
end