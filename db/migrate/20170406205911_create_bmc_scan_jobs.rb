class CreateBmcScanJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :bmc_scan_jobs do |t|
      t.string :name
      t.string :start_address
      t.string :end_address
      t.integer :status

      t.timestamps
    end
  end
end
