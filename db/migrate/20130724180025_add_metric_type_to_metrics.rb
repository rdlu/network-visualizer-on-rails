class AddMetricTypeToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :metric_type, :string, :null => false, default: 'active'
  end
end
