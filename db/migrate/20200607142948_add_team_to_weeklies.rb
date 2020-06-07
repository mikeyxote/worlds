class AddTeamToWeeklies < ActiveRecord::Migration
  def change
    add_reference :weeklies, :team, index: true, foreign_key: true
  end
end
