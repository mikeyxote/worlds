class AddSegmentsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :event_segments, :string
  end
end
