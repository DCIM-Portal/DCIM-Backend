class CreateBruteLists < ActiveRecord::Migration[5.0]
  def change
    create_table :brute_lists do |t|
      t.string :list_name

      t.timestamps
    end
  end
end