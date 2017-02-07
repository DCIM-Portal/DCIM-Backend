class AddScansToResults < ActiveRecord::Migration[5.0]
  def change
    add_reference :scan_results, :ilo_scan_job, index: true
  end
end
