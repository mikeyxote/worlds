class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.references :user, index: true, foreign_key: true
      t.references :event, index: true, foreign_key: true
      t.integer :kom
      t.integer :sprint
      t.integer :finish

      t.timestamps null: false
    end
  end
end
