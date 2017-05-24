class ZonesController < ApplicationController

  before_action :set_zone, only: [:show, :edit, :update, :destroy]
  layout "bmc_page"

  def index
    @zones = Zone.all
  end

  def new
    @zone = Zone.new
  end

  def edit
  end

  def create
    @zone = Zone.new(zone_params)
    respond_to do |format|
      if @zone.save
        format.html { redirect_to zones_url }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @zone.update(zone_params)
        @zone.save
        format.html { redirect_to @zone }
      else
        format.html { render :edit }
      end
    end
  end

  def show
  end

  def destroy
    @zone.destroy
    respond_to do |format|
      format.html { redirect_to zones_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_zone
      @zone = Zone.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def zone_params
      params.require(:zone).permit(:name)
    end

end
