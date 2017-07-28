class AddForemanLocationId < ActiveRecord::Migration[5.1]
  def change
    add_column :zones, :foreman_location_id, :integer
  end
end
