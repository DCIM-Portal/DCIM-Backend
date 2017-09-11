class Admin::BmcHostsController < AdminController

  before_action :set_bmc_host, only: [:show, :update, :destroy]
  layout "admin_page"
  add_breadcrumb "Home", "/"
  add_breadcrumb "Admin", :admin_path
  add_breadcrumb "BMC Hosts", :admin_bmc_hosts_path

  def index
    @bmc_hosts = BmcHost.all

    #Set Custom Filters for Datatables
    @filters = {}
    @filters[:bmc_host] = {
      zone: Zone.all.map { |key| [ key["name"],key["id"] ] }.to_h,
      power_status: BmcHost.power_statuses,
      sync_status: BmcHost.sync_statuses
    }
    @filters[:onboard_request] = {
      status: OnboardRequest.statuses,
      step: OnboardRequest.steps
    }

    respond_to do |format|
      format.html
      format.json { render json: @bmc_hosts }
    end

  end

  def show
    add_breadcrumb @bmc_host.ip_address, admin_bmc_host_path
  end

  def update
    @bmc_host.refresh!
  end

  def multi_refresh
    selected_hosts = BmcHost.where(id: params[:selected_ids])
    # TODO: Parallelize this.
    selected_hosts.each {|host| host.refresh!}
  end

  def destroy
  end

  def onboard_modal
    selected_hosts = ids_to_bmc_hosts(params[:selected_ids])
    green, yellow, red = validate_bmc_hosts_for_onboard(selected_hosts)
    respond_to do |format|
      format.html { render layout: false, locals: { hosts: selected_hosts, red: red, yellow: yellow, green: green } }
    end
  end

  def multi_onboard
    add_breadcrumb "Onboard Request".html_safe
    input = params[:onboard]
    unless input.is_a?(ActionController::Parameters) && input[:bmc_host_ids].is_a?(Array)
      ids = []
      #redirect_back fallback_location: {action: 'index'}
      #return
    else
      ids = input[:bmc_host_ids]
    end

    puts "HERE ARE IDS"
    puts ids

    selected_hosts = ids_to_bmc_hosts(ids)
    green, yellow, red = validate_bmc_hosts_for_onboard(selected_hosts)

    onboard_requests = []
    green.each do |item|
      bmc_host = item[:bmc_host]
#      bmc_host.update(onboard_request: OnboardRequest.new(bmc_host: bmc_host))
      onboard_requests << bmc_host.onboard_request
    end
    yellow.each do |item|
      bmc_host = item[:bmc_host]
      onboard_requests << bmc_host.onboard_request
    end

    onboard_requests.each do |onboard_request|
#      OnboardJob.perform_later(foreman_resource: YAML::dump(@foreman_resource), request: onboard_request)
    end

    respond_to do |format|
      format.html { render locals: { hosts: selected_hosts, red: red, yellow: yellow, green: green } }
    end
  end

  private

  def set_bmc_host
    @bmc_host = BmcHost.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_back fallback_location: {action: 'index'}
  end

  def ids_to_bmc_hosts(ids)
    BmcHost.includes(:onboard_request).references(:onboard_request).where(id: ids)
  end

  def validate_bmc_hosts_for_onboard(bmc_hosts)
    list_bmc_host_unonboardable = []
    list_onboard_request_exists = []
    list_no_onboard_request_yet = []
    bmc_hosts.each do |host|
      unonboardable_reason = nil
      begin
        host.validate_onboardable
      rescue RuntimeError => unonboardable_reason
      end
      # BmcHost fails validation
      if unonboardable_reason
        list_bmc_host_unonboardable << { bmc_host: host, exception: unonboardable_reason }
      # OnboardRequest exists
      elsif host.onboard_request
        list_onboard_request_exists << { bmc_host: host, onboard_request: host.onboard_request }
      # New OnboardRequest
      else
        list_no_onboard_request_yet << { bmc_host: host }
      end
    end
    [list_no_onboard_request_yet, list_onboard_request_exists, list_bmc_host_unonboardable]
  end

end
