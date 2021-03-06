class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.bigint :strava_id
      t.references :user, index: true, foreign_key: true
      t.string :name
      t.float :distance
      t.datetime :start_date
      t.boolean :trainer
      t.bigint :strava_athlete_id

      t.timestamps null: false
    end
  end
end
