class Admin::EnclosureRacksController < AdminController
  include Admin::Filters
  layout 'admin_page'
  add_breadcrumb 'Home', '/'
  add_breadcrumb 'Admin', :admin_path
  add_breadcrumb 'Datacenter Zones', :admin_zones_path

  def index
    @zone = Zone.find(params[:zone_id])
    add_breadcrumb @zone.name, admin_zone_path(@zone.id)
    add_breadcrumb 'Racks', admin_zone_enclosure_racks_path
    @enclosure_racks = @zone.enclosure_racks
    respond_to do |format|
      format.html
      format.json { render json: @enclosure_racks }
    end
  end

  def show; end

  def create; end

  def update; end

  def destroy; end
end
