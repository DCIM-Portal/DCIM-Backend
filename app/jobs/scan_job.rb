require 'rubyipmi'
require 'ipaddr'
require 'thread/pool'

class ScanJob < ApplicationJob
  queue_as :default

  def perform(ilo_scan_job)
    #Update status to show that job is running
    ilo_scan_job.update_attributes(status: "Scanning for Available Servers...")
    #Method to convert start and end IP strings into IPv4 range
    def convert_ip_range(start_ip, end_ip)
      start_ip = IPAddr.new(start_ip)
      end_ip   = IPAddr.new(end_ip)
      (start_ip..end_ip).map(&:to_s)
    end

    #Convert start and end IP into a range
    @ip_range = convert_ip_range(ilo_scan_job.start_ip, ilo_scan_job.end_ip)

    #Define thread pool
    pool = Thread.pool(200)

    #Use Discover to see which iLOs responds
    return_ip = []
    @ip_range.each do | r|
      pool.process do
        return_ip << `ipmiutil discover -b #{r} | grep -Eo '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'`
      end
    end

    #Pause for 5 seconds
    sleep 5

    #Strip out any blanks and line returns in the result
    no_blank = return_ip.select(&:present?)
    @ipmi_scan = no_blank.map{|x| x.strip }

    #Create new hash to store results in
    @scan_results = {}

    #Take each returned IP and grab the model and serial
    @ipmi_scan.each_with_index do |address, i|
      #Use thread pool to execute in parallel
      pool.process do
        get_fru = Rubyipmi.connect(ilo_scan_job.ilo_username, ilo_scan_job.ilo_password, address, "freeipmi", {:driver => "lan20"} ).fru.list
        #IBM or HP Server
        if !get_fru["default_fru_device"].nil?
          model = get_fru["default_fru_device"]["product_name"]
          serial = get_fru["default_fru_device"]["product_serial_number"]
        #Dell Server
        elsif !get_fru["system_board"].nil?
          model = get_fru["system_board"]["board_product_name"]
          serial = get_fru["system_board"]["product_serial_number"]
        #Unable to access BMC
        else
          model = "Unable to Access Device"
          serial = "N/A"
        end

        @scan_results[i] = {address: address, model: model, serial: serial}
      end
    end

    pool.shutdown

    #Update job status
    ilo_scan_job.status = "Completed Initial Scan"

    #Save the updated job status
    ilo_scan_job.save
 
  end
end
