class BmcHostsController < ApplicationController

  before_action :set_bmc_host, only: [:show, :update, :destroy]
  layout "bmc_page"
  add_breadcrumb "Home", "/"
  add_breadcrumb "Admin", :admin_index_path

  def index
    add_breadcrumb "BMC Hosts", bmc_hosts_path
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
      format.json { render json: BmcHostDatatable.new(view_context, params) }
    end

  end

  def show
  end

  def update
  end

  def destroy
  end

  private

    def set_bmc_host
      @bmc_host = BmcHost.find(params[:id])
    end

end
