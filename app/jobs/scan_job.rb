require 'rubyipmi'
require 'ipaddr'
require 'timeout'

class ScanJob < ApplicationJob
  queue_as :default


  def perform(ilo_scan_job)

    sleep 2

    #Update status to show that job is running
    ilo_scan_job.update_attributes(status: "Searching for Servers")

    #Method to convert start and end IP strings into IPv4 range
    def convert_ip_range(start_ip, end_ip)
      start_ip = IPAddr.new(start_ip)
      end_ip   = IPAddr.new(end_ip)
      (start_ip..end_ip).map(&:to_s)
    end

    #Convert start and end IP into a range with timeout
    begin
      Timeout::timeout(60) {
        @ip_range = convert_ip_range(ilo_scan_job.start_ip, ilo_scan_job.end_ip)
      }
    rescue Timeout::Error
      @ip_range = ["0.0.0.0"]
    end

    #Define thread pool
    pool = Concurrent::FixedThreadPool.new(100)
    cache_pool = Concurrent::CachedThreadPool.new

    #Use Discover to see which iLOs responds
    return_ip = []
    @ip_range.each do | r|
      cache_pool.post do
        return_ip << `ipmiutil discover -b #{r} | grep -Eo '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'`
      end
    end

    #Wait for workers to finish
    cache_pool.shutdown
    cache_pool.wait_for_termination(timeout = 120)

    #Strip out any blanks and line returns in the result
    no_blank = return_ip.select(&:present?)
    @ipmi_scan = no_blank.map{|x| x.strip }

    #Get Server Count
    @count = @ipmi_scan.count

    #Update Server Count
    ilo_scan_job.count = @count

    #Update status to show number of servers found
    if @count > 1
      ilo_scan_job.update_attributes(status: "Found #{@count} Servers - Gathering Details")
    elsif @count == 1
      ilo_scan_job.update_attributes(status: "Found #{@count} Server - Gathering Details")
    else
      ilo_scan_job.update_attributes(status: "No Servers Responded")
      sleep 2
    end

    #Take each returned IP and grab the model and serial
    def do_ipmi_scan(address, ilo_scan_job)
      #Flush SDR cache if it exists
      system "ipmi-sensors -h #{address} -u #{ilo_scan_job.ilo_username} -p #{ilo_scan_job.ilo_password} -f -Q"
      #Obtain fru information of server
      conn = Rubyipmi.connect(ilo_scan_job.ilo_username, ilo_scan_job.ilo_password, address, "freeipmi", {:driver => "lan20"} )
      begin
        get_fru = conn.fru.list
      rescue
        get_fru = conn.fru.list
      end
      #IBM or HP Server
      if !get_fru["default_fru_device"].nil?
        model = get_fru["default_fru_device"].values_at('board_manufacturer', 'product_name').join(' ')
        serial = get_fru["default_fru_device"]["product_serial_number"]
      #Dell Server
      elsif !get_fru["system_board"].nil?
        model = get_fru["system_board"].values_at('board_manufacturer', 'board_product_name').join(' ')
        serial = get_fru["system_board"]["product_serial_number"]
      #Cisco Server
      elsif !get_fru["fru_ram"].nil?
        model = get_fru["fru_ram"].values_at('board_manufacturer', 'product_name').join(' ')
        serial = get_fru["fru_ram"]["product_serial_number"]
      #Unable to access BMC or unsupported model
      else
        model = "Unable to Access Device"
        serial = "N/A"
      end
      return {address: address, model: model, serial: serial, job_id: ilo_scan_job.id}
    end

    #Save the scan result to the database
    def save_scan_result(address, ilo_scan_job, hash)
      scan_result = ScanResult.new
      conn = Rubyipmi.connect(ilo_scan_job.ilo_username, ilo_scan_job.ilo_password, address, "ipmitool", {:driver => "lan20"} )
      scan_result.ilo_address = hash[:address]
      scan_result.server_model = hash[:model]
      scan_result.server_serial = hash[:serial]
      scan_result.ilo_scan_job_id = hash[:job_id]
      if conn.chassis.power.on?
        scan_result.power_status = "On"
      elsif conn.chassis.power.off?
        scan_result.power_status = "Off"
      else
        scan_result.power_status = "Unknown"
      end
      scan_result.provision_status = "Initial Scan"
      scan_result.save
    end

    #Execute the job
    @ipmi_scan.each_with_index do |address|
      Concurrent::Promise.execute(executor: pool) do
        hash = do_ipmi_scan(address, ilo_scan_job)
        ActiveRecord::Base.connection_pool.with_connection do
          save_scan_result(address, ilo_scan_job, hash)
        end
      end
    end

    #Wait for workers to finish
    pool.shutdown
    pool.wait_for_termination(timeout = 300)

    #Update job status
    ilo_scan_job.status = "Scan Complete"

    #Save the updated job status
    ilo_scan_job.save

  end

end
