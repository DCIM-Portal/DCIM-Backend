class BmcScanJob < ApplicationJob
  include MonitorMixin
  queue_as :default

  def perform(**kwargs)
    begin
      @foreman_resource = kwargs[:foreman_resource]
      @foreman_resource = YAML::load(@foreman_resource) unless @foreman_resource.is_a? Dcim::ForemanApi
    rescue RuntimeError
      # Default to system-wide ForemanApi
      @foreman_resource = Dcim::ForemanApiFactory.instance
    end
    @request = kwargs[:request]
    @logger = kwargs[:logger] || Sidekiq::Logging.logger || Rails.logger

    @request.error_message = nil
    @request.bmc_hosts.destroy_all
    @request.update(status: :in_progress)

    begin
      smart_proxy = Dcim::SmartProxyApiFactory.instance(@request.zone.foreman_location_id)
    rescue RuntimeError => e
      @logger.error e
      @request.update(status: :smart_proxy_unreachable)
      return false
    end
    @logger.info "Suitable Smart Proxy found: " + smart_proxy.instance_variable_get(:@resource).instance_variable_get(:@url)

    begin
      bmc_hosts = list_bmc_hosts(smart_proxy)
    rescue Dcim::BmcScanError => e
      @request.error_message = e.message
      @request.update(status: :invalid_range)
      return false
    end
    @logger.info "BMC hosts found: " + bmc_hosts.to_s

    pool = Concurrent::FixedThreadPool.new(100)

    promises = {}
    bmc_hosts.each do |bmc_host_ip|
      bmc_host = BmcHost.find_by(ip_address: bmc_host_ip)
      bmc_host = BmcHost.new(ip_address: bmc_host_ip,
                             zone: @request.zone) if !bmc_host
      bmc_host.bmc_scan_requests << @request
      bmc_host.save!
      bmc_host.smart_proxy = smart_proxy
      promises[bmc_host_ip] = Concurrent::Promise.new(executor: pool) do
        @logger.debug bmc_host_ip + ": BMC host record established"
        secrets = [nil]
        synchronize do
          secrets.push *@request.brute_list.brute_list_secrets
        end
        secrets.each do |secret|
          begin
            success = nil
            ::ActiveRecord::Base.connection_pool.with_connection do
              success = bmc_host.refresh!(secret)
              @logger.debug bmc_host_ip + ": BMC host updated"
            end
            break if success
          rescue Dcim::InvalidCredentialsError => e
            no_credentials_worked = true
            next
          end
        end
      end
    end

    ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
      promises.each do |bmc_host_ip, promise|
        promise.execute
      end

      pool.shutdown
      pool.wait_for_termination(timeout = 180)
    end

    promises.each do |bmc_host_ip, promise|
      if promise.rejected?
        error = promise.reason
        @logger.warn bmc_host_ip + ": Promise rejected with reason: " + error.to_s
        bmc_host = BmcHost.find_by(ip_address: bmc_host_ip)
        begin
          bmc_host.sync_status = error.class.name.demodulize.underscore
        rescue ArgumentError
          bmc_host.sync_status = :stack_trace
          bmc_host.error_message = error.class.name + ": " + error.message + "\n" + error.backtrace.join("\n")
        end
        bmc_host.save!
      end
    end

    @request.reload
    @request.update(status: :scan_complete)
    true
  end

  private

  def list_bmc_hosts(smart_proxy_resource)
    response = smart_proxy_resource.onboard.bmc.scan.range(@request.start_address, @request.end_address).get(timeout: 600).to_hash
    raise Dcim::BmcScanError, response["error"] if response.key?("error")
    response["result"]
  end

end
