class CreateBmcScanRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :bmc_scan_requests do |t|
      t.string :name
      t.string :start_address
      t.string :end_address
      t.integer :status
      t.string :error_message

      t.timestamps
    end
    add_index :bmc_scan_requests, :name, unique: true
  end
end
