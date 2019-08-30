class CreateSegments < ActiveRecord::Migration
  def change
    create_table :segments do |t|
      t.integer :points
      t.string :name
      t.integer :strava_id
      t.float :max_grade
      t.float :average_grade
      t.integer :climb_category
      t.integer :star_count

      t.timestamps null: false
    end
  end
end
