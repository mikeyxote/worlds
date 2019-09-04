class ChangeStartToDateTimeInEvents < ActiveRecord::Migration
  def up
    change_column :events, :start_date, :datetime
  end
  
  def down
    change_column :events, :start_date, :integer
  end
end
