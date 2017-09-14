class CreateOnboardRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :onboard_requests do |t|
      t.integer :status

      t.timestamps
    end
  end
end
