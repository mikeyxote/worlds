class AddDateToResults < ActiveRecord::Migration
  def change
    add_column :results, :start_date, :datetime
  end
end
