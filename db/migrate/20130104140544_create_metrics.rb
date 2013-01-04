class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string  :name
      t.string  :plugin
      t.string  :desc
      t.integer :profile_id
      t.boolean :reverse
      t.boolean :order

      t.timestamps
    end

    add_index :name, :profile_id, :unique => true

  end
end
