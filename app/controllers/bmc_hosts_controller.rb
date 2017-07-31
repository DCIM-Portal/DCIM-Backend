class BmcHostsController < ApplicationController

  before_action :set_bmc_host, only: [:show, :update, :destroy]
  layout "bmc_page"

  def index
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
