class SystemsRefreshJob < ApplicationJob
  queue_as :default

  def perform(system_ids)
    systems = System.where(id: system_ids)

    pool = Concurrent::FixedThreadPool.new(100)

    promises = {}

    systems.each do |system|
      promises[system] = Concurrent::Promise.new(executor: pool) do
        system.refresh!
      end
    end

    ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
      promises.each_value(&:execute)

      pool.shutdown
      pool.wait_for_termination(180)
    end
  end
end
