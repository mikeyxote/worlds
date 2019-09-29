class AddCategoryToPoints < ActiveRecord::Migration
  def change
    add_column :points, :category, :string
  end
end
