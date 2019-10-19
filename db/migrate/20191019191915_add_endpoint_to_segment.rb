class AddEndpointToSegment < ActiveRecord::Migration
  def change
    add_column :segments, :endpoint, :string
  end
end
