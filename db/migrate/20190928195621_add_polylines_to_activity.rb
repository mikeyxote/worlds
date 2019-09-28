class AddPolylinesToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :polyline, :string
    add_column :activities, :summary_polyline, :string
  end
end
