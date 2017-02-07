class AddCountToIloScanJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :ilo_scan_jobs, :count, :integer
  end
end
