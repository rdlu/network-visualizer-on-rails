class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.text :description
      t.integer :throughput

      t.references :connection_profile

      t.timestamps
    end

    add_index :plans, :name, :unique => true
  end
end
