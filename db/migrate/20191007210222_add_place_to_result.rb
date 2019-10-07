class AddPlaceToResult < ActiveRecord::Migration
  def change
    add_column :results, :place, :integer
  end
end
