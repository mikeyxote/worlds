class AddValueToFeature < ActiveRecord::Migration
  def change
    add_column :features, :val, :integer
  end
end
