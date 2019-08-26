class AddStravaIdToEfforts < ActiveRecord::Migration
  def change
    add_column :efforts, :strava_id, :integer
  end
end
