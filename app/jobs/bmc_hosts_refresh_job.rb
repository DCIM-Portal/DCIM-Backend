class BmcHostsRefreshJob < ApplicationJob
  queue_as :default

  def perform(host_ids)
    hosts = BmcHost.where(id: host_ids)

    pool = Concurrent::FixedThreadPool.new(100)

    promises = {}

    hosts.each do |host|
      promises[host] = Concurrent::Promise.new(executor: pool) do
        host.refresh!
      end
    end

    ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
      promises.each do |host, promise|
        promise.execute
      end

      pool.shutdown
      pool.wait_for_termination(timeout = 180)
    end

  end
end
