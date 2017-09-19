class Admin::BmcScanRequestsController < AdminController

  before_action :set_bmc_scan_request, only: [:show, :update, :destroy]
  before_action :get_dashboard_hosts, only: [:check_foreman_reachable]
  include Admin::Filters
  layout "admin_page"
  add_breadcrumb "Home", "/"
  add_breadcrumb "Admin", :admin_path
  add_breadcrumb "BMC Scans", :admin_bmc_scan_requests_path

  def index
    @bmc_scan_requests = BmcScanRequest.all
    @bmc_scan_request = BmcScanRequest.new
    @zones = Zone.all
    @creds = BruteList.all
    pick_filters(:bmc_scan_request, zone_filters, bmc_scan_request_filters)
    respond_to do |format|
      format.html
      format.json { render json: @bmc_scan_requests }
    end
  end

  def show
    add_breadcrumb @bmc_scan_request.name, admin_bmc_scan_request_path
    @zones = Zone.all
    @creds = BruteList.all
    pick_filters(:bmc_host, bmc_host_filters)
    respond_to do |format|
      format.html
      format.json { render json: @bmc_scan_request.as_json(include: ['brute_list', 'zone']) }
    end
  end

  def check_foreman_reachable
    @zone_count = Zone.count
    @cred_count = BruteList.count
    render :partial => "check_foreman_reachable"
  end

  def create
    @bmc_scan_request = BmcScanRequest.new(bmc_scan_request_params)
    @bmc_scan_request.status = nil
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
        @bmc_scan_request.status = nil
        @bmc_scan_request.save!
        format.json { render json: @bmc_scan_request }
        BmcScanJob.perform_later(foreman_resource: YAML::dump(@foreman_resource), request: @bmc_scan_request)
      else
        format.json { render json: @bmc_scan_request.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @bmc_scan_request.destroy!
    respond_to do |format|
      format.html { redirect_to admin_bmc_scan_requests_url }
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
