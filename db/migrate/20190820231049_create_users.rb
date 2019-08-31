class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :firstname
      t.string :lastname
      t.string :username
      t.string :strava_token
      t.string :strava_refresh_token
      t.integer :strava_expiration
      t.integer :strava_id
      t.boolean :director, :default => false
      t.boolean :developer, :default => false
      t.string :profile_medium
      t.string :profile

      t.timestamps null: false
    end
  end
end
