class AddActivitiesToEfforts < ActiveRecord::Migration
  def change
    add_reference :efforts, :activity, index: true, foreign_key: true
  end
end
