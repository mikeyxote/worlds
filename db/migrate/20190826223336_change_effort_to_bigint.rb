class ChangeEffortToBigint < ActiveRecord::Migration
  def change
    change_column :efforts, :strava_id, :bigint
  end
end
