class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :strava_token
      t.string :strava_refresh_token
      t.integer :strava_expiration
      t.integer :strava_id
      t.boolean :admin, :default => false
      t.boolean :developer, :default => false
      t.string :avatar

      t.timestamps null: false
    end
  end
end
