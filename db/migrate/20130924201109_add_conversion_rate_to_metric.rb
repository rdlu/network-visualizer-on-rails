class AddConversionRateToMetric < ActiveRecord::Migration
  def change
    add_column :metrics, :conversion_rate, :float
  end
end
