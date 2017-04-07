class ChangeColumnNames < ActiveRecord::Migration[5.0]
  def change
    rename_column :bmc_hosts, :address, :ip_address
    rename_column :bmc_scan_jobs, :scan_name, :name
    rename_column :bmc_scan_jobs, :job_status, :status
    rename_column :brute_lists, :list_name, :name
    rename_column :provision_jobs, :provision_status, :status
    rename_column :provision_jobs, :provision_step, :step
    rename_column :secrets, :sort, :order
  end
end
