class CreateWeeklies < ActiveRecord::Migration
  def change
    create_table :weeklies do |t|
      t.references :segment, index: true, foreign_key: true
      t.datetime :start_date
      t.datetime :end_date
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
