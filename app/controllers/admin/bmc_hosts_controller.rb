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
    selected_hosts.each {|host| host.refresh!}
  end

  def destroy
  end

  def onboard_modal
    selected_hosts = BmcHost.includes(:onboard_request).references(:onboard_request).where(id: params[:selected_ids])
    list_bmc_host_unonboardable = []
    list_onboard_request_exists = []
    list_no_onboard_request_yet = []
    selected_hosts.each do |host|
      unonboardable_reason = nil
      begin
        host.validate_onboardable
      rescue RuntimeError => unonboardable_reason
      end
      # BmcHost fails validation
      if unonboardable_reason
        # TODO: Add this host to fail list
      # OnboardRequest exists
      elsif host.onboard_request
        # TODO: Add this host to override prompt list
      # New OnboardRequest
      else
        # TODO: Add this host to onboard list
      end
    end
    respond_to do |format|
      format.html { render layout: false, locals: {hosts: selected_hosts} }
    end
  end

  def multi_onboard
    hosts_to_onboard = BmcHost.includes(:onboard_request).references(:onboard_request).where(id: params[:hosts][:bmc_host_ids])
    hosts_to_onboard.each do |host|
      unonboardable_reason = nil
      begin
        host.validate_onboardable
      rescue RuntimeError => unonboardable_reason
      end
      # BmcHost fails validation
      if unonboardable_reason
        # TODO: Add this host to fail list
      # OnboardRequest exists
      elsif host.onboard_request
        # TODO: Add this host to override prompt list
      # New OnboardRequest
      else
       onboard_request = OnboardRequest.new(bmc_host: host) if host.onboard_request.nil?
        onboard_request.save! if onboard_request
        if !host.serial.nil? && host.onboard_request.try(:status) != "success"
#          OnboardJob.perform_later(foreman_resource: YAML::dump(@foreman_resource), request: host.onboard_request)
        end
      end
    end
  end

  def onboard_confirm
  end

  private

  def set_bmc_host
    @bmc_host = BmcHost.find(params[:id])
  end

end
