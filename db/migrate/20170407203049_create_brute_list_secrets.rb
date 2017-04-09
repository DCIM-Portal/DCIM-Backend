class CreateBruteListSecrets < ActiveRecord::Migration[5.0]
  def change
    create_table :brute_list_secrets do |t|
      t.string :username
      t.string :password
      t.integer :order

      t.timestamps
    end
  end
end
