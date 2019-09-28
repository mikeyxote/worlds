class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.references :activity, index: true, foreign_key: true
      t.references :event, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
