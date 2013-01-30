class AddDescriptionToThresholds < ActiveRecord::Migration
  def change
    add_column :thresholds, :description, :string
  end
end
