class CreateProvisionJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :provision_jobs do |t|
      t.integer :provision_status
      t.integer :provision_step

      t.timestamps
    end
  end
end
