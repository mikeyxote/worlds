class AddEventToActivities < ActiveRecord::Migration
  def change
    add_reference :activities, :event, index: true, foreign_key: true
  end
end
