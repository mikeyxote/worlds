class AddStopdateToEfforts < ActiveRecord::Migration
  def change
    add_column :efforts, :stop_date, :datetime
  end
end
