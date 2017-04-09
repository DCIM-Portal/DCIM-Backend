class CreateBmcHostSecrets < ActiveRecord::Migration[5.0]
  def change
    create_table :bmc_host_secrets do |t|
      t.string :username
      t.string :password

      t.timestamps
    end
  end
end
