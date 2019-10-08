class AddSeriesToEvent < ActiveRecord::Migration
  def change
    add_reference :events, :series, index: true, foreign_key: true
  end
end
