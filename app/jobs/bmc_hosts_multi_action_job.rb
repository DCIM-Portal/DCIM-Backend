class BmcHostsMultiActionJob < ApplicationJob
  queue_as :default

  def perform(bmc_action, host_ids)
    hosts = BmcHost.where(id: host_ids)

    pool = Concurrent::FixedThreadPool.new(100)

    promises = {}

    hosts.each do |host|
      promises[host] = Concurrent::Promise.new(executor: pool) do
        host.send(bmc_action)
      end
    end

    ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
      promises.each_value(&:execute)

      pool.shutdown
      pool.wait_for_termination(180)
    end
  end

end
