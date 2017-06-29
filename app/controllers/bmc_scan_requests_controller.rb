class BmcScanRequestsController < ApplicationController
  
  def index
    @bmc_scan_requests = BmcScanRequest.all
    render layout: "bmc_page"
  end

  #def show
  #  @scan_results = ScanResult.where(bmc_scan_job_id: @bmc_scan_job.id).order('bmc_address ASC')
  #end

  def new
    @bmc_scan_request = BmcScanRequest.new
  end

  def edit
  end

  def create
    @bmc_scan_request = BmcScanRequest.new(bmc_scan_request_params)
    @bmc_scan_request.status = 0
    respond_to do |format|
      if @bmc_scan_request.save
        format.html { redirect_to bmc_scan_requests_url }
        #ScanJob.perform_later(@bmc_scan_request)
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @bmc_scan_request.update(bmc_scan_request_params)
        @bmc_scan_request.status = 0
        @bmc_scan_request.save
        format.html { redirect_to @bmc_scan_request }
        #ScanResult.where(bmc_scan_job_id: @bmc_scan_job.id).destroy_all
        #ScanJob.perform_later(@bmc_scan_job)
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @bmc_scan_request.status = 5
    #ScanResult.where(bmc_scan_job_id: @bmc_scan_job.id).destroy_all
    @bmc_scan_request.destroy
    respond_to do |format|
      format.html { redirect_to bmc_scan_requests_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bmc_scan_request_
      @bmc_scan_request = BmcScanRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bmc_scan_request_params
      params.require(:bmc_scan_request).permit(:zone_id, :start_address, :end_address, :name)
    end

end
