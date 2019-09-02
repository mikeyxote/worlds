class CreateEfforts < ActiveRecord::Migration
  def change
    create_table :efforts do |t|
      t.references :user, index: true, foreign_key: true
      t.references :segment, index: true, foreign_key: true
      t.float :start_date
      t.integer :elapsed_time
      t.bigint :strava_id
      t.bigint :strava_segment_id
      t.bigint :strava_athlete_id

      t.timestamps null: false
    end
  end
end
