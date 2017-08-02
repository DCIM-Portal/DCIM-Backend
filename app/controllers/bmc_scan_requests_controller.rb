class BmcScanRequestsController < ApplicationController

  before_action :set_bmc_scan_request, only: [:show, :update, :destroy]
  before_action :get_dashboard_hosts, only: [:api_bmc_scan_request]
  layout "bmc_page"
  add_breadcrumb "Home", "/"
  add_breadcrumb "Admin", :admin_index_path

  def index
    add_breadcrumb "BMC Scans", bmc_scan_requests_path 
    @bmc_scan_requests = BmcScanRequest.all
    @bmc_scan_request = BmcScanRequest.new
    @zones = Zone.all
    @creds = BruteList.all
    respond_to do |format|
      format.html
      format.json {
        render json: @bmc_scan_requests.collect {
          |scan| {
            id:  scan.id,
            name: scan.name,
            start_address: scan.start_address,
            end_address: scan.end_address,
            status: scan.status,
            brute_list: scan.brute_list.name,
            zone: scan.zone.name,
            created_at: scan.created_at,
            url: bmc_scan_request_path(BmcScanRequest.find(scan.id))
          }
        }
      }
    end
  end

  def show
    add_breadcrumb "BMC Scans", bmc_scan_requests_path
    add_breadcrumb @bmc_scan_request.name, bmc_scan_request_path
    @zones = Zone.all
    @creds = BruteList.all
    respond_to do |format|
      format.html
      format.json { render json: @bmc_scan_request.to_json( include: :bmc_hosts ) }
    end
  end

  def api_bmc_scan_request
    @zone_count = Zone.count
    @cred_count = BruteList.count
    render :partial => "api_bmc_scan_request"
  end

  def create
    @bmc_scan_request = BmcScanRequest.new(bmc_scan_request_params)
    @bmc_scan_request.status = 0
    respond_to do |format|
      if @bmc_scan_request.save
        format.json { render json: @bmc_scan_request }
        BmcScanJob.perform_later(foreman_resource: YAML::dump(@foreman_resource), request: @bmc_scan_request)
      else
        format.json { render json: @bmc_scan_request.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @bmc_scan_request.update(bmc_scan_request_params)
        @bmc_scan_request.bmc_hosts.destroy_all
        @bmc_scan_request.status = 0
        @bmc_scan_request.save!
        format.json { render json: @bmc_scan_request }
        BmcScanJob.perform_later(foreman_resource: YAML::dump(@foreman_resource), request: @bmc_scan_request)
      else
        format.json { render json: @bmc_scan_request.errors.full_messages, status: :unprocessable_entity }
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

    def foreman_dashboard
      @foreman_resource.api.dashboard
    end


    #Verify Foreman Reachable
    def get_dashboard_hosts
      begin
        result = foreman_dashboard.get
        result["total_hosts"]
      rescue Exception => e
        @logger.error(exception: e)
        []
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_bmc_scan_request
      @bmc_scan_request = BmcScanRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bmc_scan_request_params
      params.require(:bmc_scan_request).permit(:brute_list_id, :zone_id, :start_address, :end_address, :name)
    end

end
