class Admin::BmcHostsController < AdminController
  before_action :set_bmc_host, only: %i[show update destroy]
  include Admin::Filters
  layout 'admin_page'
  add_breadcrumb 'Home', '/'
  add_breadcrumb 'Admin', :admin_path
  add_breadcrumb 'BMC Hosts', :admin_bmc_hosts_path

  def index
    @bmc_hosts = BmcHost.all

    pick_filters(:bmc_host, zone_filters, bmc_host_filters)

    respond_to do |format|
      format.html
      format.json { render json: @bmc_hosts }
    end
  end

  def show
    add_breadcrumb @bmc_host.ip_address, admin_bmc_host_path
    respond_to do |format|
      format.html
      format.json { render json: @bmc_host.as_json(include: ['system']) }
    end
  end

  def update
    BmcHostsRefreshJob.perform_later([@bmc_host.id])
  end

  def multi_refresh
    BmcHostsRefreshJob.perform_later(params[:selected_ids])
  end

  def destroy; end

  def onboard_modal
    selected_hosts = ids_to_bmc_hosts(params[:selected_ids])
    green, yellow, red = validate_bmc_hosts_for_onboard(selected_hosts)
    respond_to do |format|
      format.html { render layout: false, locals: { hosts: selected_hosts, red: red, yellow: yellow, green: green } }
    end
  end

  private

  def set_bmc_host
    @bmc_host = BmcHost.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_back fallback_location: { action: 'index' }
  end
end
