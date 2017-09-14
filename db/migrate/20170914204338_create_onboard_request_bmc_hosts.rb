class CreateOnboardRequestBmcHosts < ActiveRecord::Migration[5.1]
  def change
    create_table :onboard_request_bmc_hosts do |t|
      t.belongs_to :bmc_host
      t.belongs_to :onboard_request

      t.timestamps
    end
  end
end
