class AddProvisionRequesttoBmcHosts < ActiveRecord::Migration[5.0]
  def change
    add_reference :provision_requests, :bmc_host, index: true
  end
end
