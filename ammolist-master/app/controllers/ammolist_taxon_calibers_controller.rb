class AmmolistTaxonCalibersController < ApplicationController
  before_action :set_ammolist_taxon_caliber, only: [:show, :edit, :update, :destroy]

  # GET /ammolist_taxon_calibers
  # GET /ammolist_taxon_calibers.json
  def index
    @ammolist_taxon_calibers = AmmolistTaxonCaliber.all
  end

  # GET /ammolist_taxon_calibers/1
  # GET /ammolist_taxon_calibers/1.json
  def show
  end

  # GET /ammolist_taxon_calibers/new
  def new
    @ammolist_taxon_caliber = AmmolistTaxonCaliber.new
  end

  # GET /ammolist_taxon_calibers/1/edit
  def edit
  end

  # POST /ammolist_taxon_calibers
  # POST /ammolist_taxon_calibers.json
  def create
    @ammolist_taxon_caliber = AmmolistTaxonCaliber.new(ammolist_taxon_caliber_params)

    respond_to do |format|
      if @ammolist_taxon_caliber.save
        format.html { redirect_to @ammolist_taxon_caliber, notice: 'Ammolist taxon caliber was successfully created.' }
        format.json { render :show, status: :created, location: @ammolist_taxon_caliber }
      else
        format.html { render :new }
        format.json { render json: @ammolist_taxon_caliber.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ammolist_taxon_calibers/1
  # PATCH/PUT /ammolist_taxon_calibers/1.json
  def update
    respond_to do |format|
      if @ammolist_taxon_caliber.update(ammolist_taxon_caliber_params)
        format.html { redirect_to @ammolist_taxon_caliber, notice: 'Ammolist taxon caliber was successfully updated.' }
        format.json { render :show, status: :ok, location: @ammolist_taxon_caliber }
      else
        format.html { render :edit }
        format.json { render json: @ammolist_taxon_caliber.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ammolist_taxon_calibers/1
  # DELETE /ammolist_taxon_calibers/1.json
  def destroy
    @ammolist_taxon_caliber.destroy
    respond_to do |format|
      format.html { redirect_to ammolist_taxon_calibers_url, notice: 'Ammolist taxon caliber was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ammolist_taxon_caliber
      @ammolist_taxon_caliber = AmmolistTaxonCaliber.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ammolist_taxon_caliber_params
      params.require(:ammolist_taxon_caliber).permit(:taxon_id, :point)
    end
end
