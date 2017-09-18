module Admin::Filters
  extend ActiveSupport::Concern

  def pick_filters(category, *args)
    @filters = {}
    filters = {}
    args.each do |item|
      filters.merge!(item)
    end
    @filters[category] = filters
    @filters
  end

  def bmc_scan_request_filters
    {
      status: BmcScanRequest.statuses
    }
  end

  def zone_filters
    {
      zone: Zone.all.map { |key| [ key["name"],key["id"] ] }.to_h
    }
  end

  def bmc_host_filters
    {
      power_status: BmcHost.power_statuses,
      sync_status: BmcHost.sync_statuses,
      onboard_status: BmcHost.onboard_statuses,
      onboard_step: BmcHost.onboard_steps
    }
  end

  def onboard_request_filters
    {
      status: OnboardRequest.statuses
    }
  end

end
