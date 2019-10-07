class CreateSeries < ActiveRecord::Migration
  def change
    create_table :series do |t|
      t.string :name
      t.string :description
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps null: false
    end
  end
end
