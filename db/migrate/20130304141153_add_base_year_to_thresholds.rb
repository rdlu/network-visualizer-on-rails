class AddBaseYearToThresholds < ActiveRecord::Migration
  def change
    add_column :thresholds, :base_year, :integer
  end
end
