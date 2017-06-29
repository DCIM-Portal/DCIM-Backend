class CreateBmcScanRequestHosts < ActiveRecord::Migration[5.0]
  def change
    create_table :bmc_scan_request_hosts, id: false do |t|
      t.belongs_to :bmc_scan_request
      t.belongs_to :bmc_host

      t.timestamps
    end
  end
end
