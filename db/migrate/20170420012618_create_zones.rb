class CreateZones < ActiveRecord::Migration[5.0]
  def change
    create_table :zones do |t|

      t.timestamps
    end
    add_reference :bmc_hosts, :zone, index: true
    add_reference :bmc_scan_requests, :zone, index: true
  end
end
