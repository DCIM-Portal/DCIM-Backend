class BmcHostsController < ApplicationController

  before_action :set_bmc_host, only: [:show, :update, :destroy]
  layout "bmc_page"
  add_breadcrumb "Home", "/"
  add_breadcrumb "Admin", :admin_index_path

  def index
    add_breadcrumb "BMC Hosts", bmc_hosts_path
    @bmc_hosts = BmcHost.all
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
