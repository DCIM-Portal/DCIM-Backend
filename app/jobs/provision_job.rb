require 'rubyipmi'

class ProvisionJob < ApplicationJob
  queue_as :default

  def perform(provision, ilo_scan_job)

    #Define thread pool
    pool = Concurrent::FixedThreadPool.new(100)

    #Power off method
    def power_down(conn)
      #Try a graceful shutdown first
      conn.chassis.power.softShutdown
      #If graceful shutdown fails, force reboot in 60 seconds
      begin
        Timeout::timeout(180) {
          sleep(10) until conn.chassis.power.off?
        }
      rescue Timeout::Error
        conn.chassis.power.off
        sleep 5
      end
      #Set false if server does not shut off
      return conn.chassis.power.off?
    end

    #Power on pxe method
    def power_on_pxe(conn)
      #Set server to boot in PXE mode
      begin
        Timeout::timeout(80) {
          conn.chassis.bootpxe(reboot=true, persistent=true)
        }
      rescue Timeout::Error
        logger.warn("Timeout Reached - PXE Boot Fail!")
      end
      for i in 0..1
        if conn.chassis.power.on?
          return true
        end
        conn.chassis.power.on
        sleep 5
      end
      #Set false if server does not power on
      return conn.chassis.power.on?
    end
    
    #Take each bmc address and boot the server into PXE mode
    provision.each do |address|
      Concurrent::Promise.execute(executor: pool) do
        conn = Rubyipmi.connect(ilo_scan_job.ilo_username, ilo_scan_job.ilo_password, address, "freeipmi", {:driver => "lan20"} )
        status_record = ScanResult.where("ilo_address = ? AND ilo_scan_job_id = ?", address, ilo_scan_job.id)
        ActiveRecord::Base.connection_pool.with_connection do
          if !power_down(conn)
            status_record.update(provision_status: 'Error: Cannot Power Off Server')
          else
            status_record.update(power_status: 'Off', provision_status: 'Server Powered Off')
          end
        end
        ActiveRecord::Base.connection_pool.with_connection do
          if !power_on_pxe(conn)
            status_record.update(provision_status: 'Error: Cannot Power On Server')
          else
            status_record.update(power_status: 'On', provision_status: 'Discovering Server')
          end
        end
      end
    end

    #Wait for threads to finish
    pool.shutdown
    pool.wait_for_termination(timeout = 300)

  end
end
