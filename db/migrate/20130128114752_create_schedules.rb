class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.timestamp :start
      t.timestamp :end
      t.integer :polling
      t.string :status

      t.references :probe

      t.timestamps
    end
  end
end
