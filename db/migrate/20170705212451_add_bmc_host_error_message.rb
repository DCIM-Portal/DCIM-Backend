class AddBmcHostErrorMessage < ActiveRecord::Migration[5.1]
  def change
    add_column :bmc_hosts, :error_message, :text
  end
end
