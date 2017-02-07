class CreateIloScanJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :ilo_scan_jobs do |t|
      t.string :start_ip
      t.string :end_ip
      t.string :ilo_username
      t.string :ilo_password
      t.string :status

      t.timestamps
    end
  end
end
