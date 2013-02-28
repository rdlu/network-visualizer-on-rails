class AddTypeToMedian < ActiveRecord::Migration
  def change
    add_column :medians, :type, :string
  end
end
