class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.datetime :start_date
      t.references :segment, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
