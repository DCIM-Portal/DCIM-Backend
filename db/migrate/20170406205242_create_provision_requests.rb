class CreateProvisionRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :provision_requests do |t|
      t.integer :status
      t.integer :step

      t.timestamps
    end
  end
end
