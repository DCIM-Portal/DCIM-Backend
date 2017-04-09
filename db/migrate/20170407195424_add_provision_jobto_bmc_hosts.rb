class AddProvisionJobtoBmcHosts < ActiveRecord::Migration[5.0]
  def change
    add_reference :provision_jobs, :bmc_host, index: true
  end
end
