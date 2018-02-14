class Admin::EnclosureRacksController < AdminController
  include Admin::Filters
  before_action :set_enclosure_rack, only: %i[show update destroy]
  layout 'admin_page'
  add_breadcrumb 'Home', '/'
  add_breadcrumb 'Admin', :admin_path
  add_breadcrumb 'Datacenter Zones', :admin_zones_path
  add_breadcrumb 'Racks', :admin_enclosure_racks_path

  # def index
  #  @zone = Zone.find(params[:zone_id])
  #  add_breadcrumb @zone.name, admin_zone_path(@zone.id)
  #  add_breadcrumb 'Racks', admin_zone_enclosure_racks_path
  #  @enclosure_racks = @zone.enclosure_racks
  #  respond_to do |format|
  #    format.html
  #    format.json { render json: @enclosure_racks }
  #  end
  # end

  def index
    @racks = EnclosureRack.all
    @zones = Zone.all
    @rack = EnclosureRack.new
    respond_to do |format|
      format.html
      format.json { render json: @racks }
    end
  end

  def show;
    add_breadcrumb @rack.name, admin_enclosure_rack_path
  end

  def create
    @rack = EnclosureRack.new(enclosure_rack_params)
    respond_to do |format|
      if CreateRacks.call(@rack) == false
        format.json { render json: { error: 'Rack already exists or invalid parameter!' }, status: :unprocessable_entity }
      else
        format.json { render json: { message: 'Enclosure Rack created!' }, status: :ok }
      end
    end
  end

  def update; end

  def destroy; end

  private

  def enclosure_rack_params
    params.require(:enclosure_rack).permit(:name, :amount, :start_at, :zone_id, :zero_pad_to, :height)
  end

  def set_enclosure_rack
    @rack = EnclosureRack.find(params[:id])
  end
end
