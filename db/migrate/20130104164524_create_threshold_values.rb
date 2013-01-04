class CreateThresholdValues < ActiveRecord::Migration
  def change
    create_table :threshold_values do |t|
      t.boolean :thresholdprofile_id
      t.boolean :metric_id
      t.integer :min
      t.integer :max

      t.timestamps
    end

    add_index :threshlodprofile_id, :metric_id, :unique => true
  end
end
