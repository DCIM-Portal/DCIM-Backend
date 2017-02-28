require 'rubyipmi'

class ProvisionJob < ApplicationJob
  queue_as :default

  def perform(provision, ilo_scan_job)

    #Define thread pool
    pool = Concurrent::FixedThreadPool.new(100)

    #Take each bmc address and reboot the server into PXE mode
    provision.each do |address|
      Concurrent::Promise.execute(executor: pool) do
        conn = Rubyipmi.connect(ilo_scan_job.ilo_username, ilo_scan_job.ilo_password, address, "freeipmi", {:driver => "lan20"} )
        conn.chassis.power.off
        #If graceful shutdown fails, force reboot in 60 seconds
        begin
          Timeout::timeout(180) {
           sleep(1) until conn.chassis.power.off?
          }
        rescue Timeout::Error
          conn.chassis.bootpxe(reboot=true, persistent=true)
        end
        sleep 5
        #Boot into PXE mode if system is off
        if conn.chassis.power.off?
          conn.chassis.bootpxe(reboot=true, persistent=true)
        end

      end
    end

    #Wait for threads to finish
    pool.shutdown
    pool.wait_for_termination(timeout = 300)

  end
end
