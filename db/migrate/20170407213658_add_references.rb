class AddReferences < ActiveRecord::Migration[5.0]
  def change
    add_reference :bmc_host_secrets, :bmc_host, index: true
    add_reference :brute_list_secrets, :brute_list, index: true
    add_reference :bmc_scan_jobs, :brute_list, index: true
  end
end
