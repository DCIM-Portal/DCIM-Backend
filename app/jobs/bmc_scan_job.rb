class BmcScanJob < ApplicationJob
  queue_as :default

  def initialize(**kwargs)
    @foreman_resource = kwargs[:foreman_resource]
    @request = kwargs[:request]
  end


  def perform
    smart_proxy = get_onboard_smart_proxy
    bmc_hosts = list_bmc_hosts(smart_proxy)

    pool = Concurrent::FixedThreadPool.new(100)

    bmc_hosts.each do |bmc_host|
      Concurrent::Promise.execute(executor: pool) do
        get_bmc_host_info(bmc_host, @request.brute_list)
      end
    end
  
  end

  private

  def get_onboard_smart_proxy
    location = @foreman_resource.api.locations(@request.zone_id).get
    location["smart_proxies"].each do |smart_proxy|
      smart_proxy_resource = Dcim::SmartProxyApi.new(url: smart_proxy["url"])
      return smart_proxy_resource if smart_proxy_resource.features.get.to_hash.include? "onboard"
    end
    false
  end

  def list_bmc_hosts(smart_proxy_resource)
    smart_proxy_resource.onboard.bmc.scan.range(@request.start_address, @request.end_address).get(timeout: 600).to_hash["result"]
  end

  def get_bmc_host_info(ip, brute_list)
    brute_list.brute_list_secrets.each do |secret|
    end
  end


end
