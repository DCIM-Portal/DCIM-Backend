class Admin::OnboardRequestsController < ApplicationController
  before_action :set_onboard_request, only: [:show, :destroy]

  add_breadcrumb "Home", "/"
  add_breadcrumb "Admin", :admin_path
  add_breadcrumb "Onboard Requests", :admin_onboard_requests_path

  def index
  end

  def show
    hosts = @onboard_request.bmc_hosts
    green, yellow, red = validate_bmc_hosts_for_onboard(hosts)

    respond_to do |format|
      format.html { render locals: { hosts: hosts, green: green, yellow: yellow, red: red } }
    end
  end

  def new_modal
    selected_hosts = ids_to_bmc_hosts(params[:selected_ids])
    green, yellow, red = validate_bmc_hosts_for_onboard(selected_hosts)
    respond_to do |format|
      format.html { render layout: false, locals: { hosts: selected_hosts, red: red, yellow: yellow, green: green } }
    end
  end

  def create
    input = params[:onboard]
    unless input.is_a?(ActionController::Parameters) && input[:bmc_host_ids].is_a?(Array)
      ids = []
      #redirect_back fallback_location: {action: 'index'}
      #return
    else
      ids = input[:bmc_host_ids]
    end

    selected_hosts = ids_to_bmc_hosts(ids)
    green, yellow, red = validate_bmc_hosts_for_onboard(selected_hosts)

    @onboard_request = OnboardRequest.new
    green.each do |item|
      bmc_host = item[:bmc_host]
      @onboard_request.bmc_hosts << bmc_host
    end
    yellow.each do |item|
      bmc_host = item[:bmc_host]
      @onboard_request.bmc_hosts << bmc_host
    end

    respond_to do |format|
      if @onboard_request.save!
#        OnboardJob.perform_later(foreman_resource: YAML::dump(@foreman_resource), request: onboard_request)
        format.html { redirect_to [:admin, @onboard_request], notice: 'Onboard request was successfully created.' }
        format.json { render :show, status: :created, location: @onboard_request }
      else
        format.html { render :new }
        format.json { render json: @onboard_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
  end

  private

  def set_onboard_request
    @onboard_request = OnboardRequest.find(params[:id])
  end

  def ids_to_bmc_hosts(ids)
    BmcHost.where(id: ids)
  end

  def validate_bmc_hosts_for_onboard(bmc_hosts)
    list_bmc_host_unonboardable = []
    list_onboard_attempted = []
    list_no_onboard_attempted = []
    bmc_hosts.each do |host|
      unonboardable_reason = nil
      begin
        host.validate_onboardable
      rescue RuntimeError => unonboardable_reason
      end
      # BmcHost fails validation
      if unonboardable_reason
        list_bmc_host_unonboardable << { bmc_host: host, exception: unonboardable_reason }
      # Onboard attempted before
      elsif host.onboard_status
        list_onboard_attempted << { bmc_host: host }
      # New onboard
      else
        list_no_onboard_attempted << { bmc_host: host }
      end
    end
    [list_no_onboard_attempted, list_onboard_attempted, list_bmc_host_unonboardable]
  end

end
