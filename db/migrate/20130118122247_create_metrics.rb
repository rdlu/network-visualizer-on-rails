class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string :name
      t.string :plugin
      t.string :description
      t.boolean :reverse
      t.integer :order

      t.timestamps
    end
  end
end
