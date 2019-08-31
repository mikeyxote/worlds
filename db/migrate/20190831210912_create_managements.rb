class CreateManagements < ActiveRecord::Migration
  def change
    create_table :managements do |t|
      t.integer :manager_id
      t.integer :managed_id

      t.timestamps null: false
    end
    add_index :managements, :manager_id
    add_index :managements, :managed_id
    add_index :managements, [:manager_id, :managed_id], unique: true
    
  end
end
