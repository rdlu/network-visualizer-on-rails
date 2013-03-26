class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :user
      t.column :uuid, "uuid"
      t.datetime :timestamp
      t.string :agent_type

      t.timestamps
    end
  end
end
