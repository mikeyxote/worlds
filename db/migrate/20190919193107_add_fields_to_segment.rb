class AddFieldsToSegment < ActiveRecord::Migration
  def change
    add_column :segments, :distance, :float
    add_column :segments, :elevation_gain, :float
    add_column :segments, :polyline, :string
  end
end
