class CreateProcesses < ActiveRecord::Migration
  def change
    create_table :processes do |t|
      t.integer :added, :null => false
      t.integer :updated, :null => false
      t.integer :status, :null => false
      t.integer :profile_id, :null => false
      t.integer :source_id, :null => false
      t.integer :destination_id, :null => false
      t.boolean :threshold, :null => false

      t.timestamps
    end

    add_index :profile_id, :source_id, :destination_id,   :unique => true

  end
end
