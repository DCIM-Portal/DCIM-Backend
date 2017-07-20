class BmcHostsController < ApplicationController

  layout "bmc_page"

  def index
    @bmc_hosts = BmcHost.all
  end

  def show
  end

  private

    def set_bmc_host
      @bmc_host = BmcHost.find(params[:id])
    end

end
