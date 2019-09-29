class AddPlaceToPoints < ActiveRecord::Migration
  def change
    add_column :points, :place, :integer
  end
end
