class AddActivityToEffort < ActiveRecord::Migration
  def change
    add_column :efforts, :strava_activity_id, :bigint
  end
end
