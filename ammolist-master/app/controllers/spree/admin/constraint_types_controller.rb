class ConstraintTypesController < ApplicationController
  before_action :set_constraint_type, only: [:show, :edit, :update, :destroy]

  # GET /constraint_types
  # GET /constraint_types.json
  def index
    @constraint_types = ConstraintType.all
  end

  # GET /constraint_types/1
  # GET /constraint_types/1.json
  def show
  end

  # GET /constraint_types/new
  def new
    @constraint_type = ConstraintType.new
  end

  # GET /constraint_types/1/edit
  def edit
  end

  # POST /constraint_types
  # POST /constraint_types.json
  def create
    @constraint_type = ConstraintType.new(constraint_type_params)

    respond_to do |format|
      if @constraint_type.save
        format.html { redirect_to @constraint_type, notice: 'Constraint type was successfully created.' }
        format.json { render :show, status: :created, location: @constraint_type }
      else
        format.html { render :new }
        format.json { render json: @constraint_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /constraint_types/1
  # PATCH/PUT /constraint_types/1.json
  def update
    respond_to do |format|
      if @constraint_type.update(constraint_type_params)
        format.html { redirect_to @constraint_type, notice: 'Constraint type was successfully updated.' }
        format.json { render :show, status: :ok, location: @constraint_type }
      else
        format.html { render :edit }
        format.json { render json: @constraint_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /constraint_types/1
  # DELETE /constraint_types/1.json
  def destroy
    @constraint_type.destroy
    respond_to do |format|
      format.html { redirect_to constraint_types_url, notice: 'Constraint type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_constraint_type
      @constraint_type = ConstraintType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def constraint_type_params
      params.require(:constraint_type).permit(:name, :variant_column_name, :unit, shipping_constraints_attributes: [:min_value, :max_value])
    end
end
