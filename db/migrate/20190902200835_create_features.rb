class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.references :event, index: true, foreign_key: true
      t.references :segment, index: true, foreign_key: true
      t.string :category
      t.integer :points

      t.timestamps null: false
    end
  end
end
