class CreateBruteLists < ActiveRecord::Migration[5.0]
  def change
    create_table :brute_lists do |t|
      t.string :name

      t.timestamps
    end
    add_index :brute_lists, :name, unique: true
  end
end
