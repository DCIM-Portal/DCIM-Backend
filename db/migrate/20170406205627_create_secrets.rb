class CreateSecrets < ActiveRecord::Migration[5.0]
  def change
    create_table :secrets do |t|
      t.string :username
      t.string :password
      t.integer :sort

      t.timestamps
    end
  end
end
