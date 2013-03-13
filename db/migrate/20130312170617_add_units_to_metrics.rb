class AddUnitsToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :view_unit, :string
    add_column :metrics, :db_unit, :string
  end
end
