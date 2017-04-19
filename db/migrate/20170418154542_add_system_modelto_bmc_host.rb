class AddSystemModeltoBmcHost < ActiveRecord::Migration[5.0]
  def change
    add_column :bmc_hosts, :system_model, :string
  end
end
