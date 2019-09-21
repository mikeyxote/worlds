class AddValuetoPoints < ActiveRecord::Migration
  def change
    add_column :points, :val, :integer
  end
end
