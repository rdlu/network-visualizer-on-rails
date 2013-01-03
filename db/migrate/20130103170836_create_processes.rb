class CreateProcesses < ActiveRecord::Migration
  def change
    create_table :processes do |t|

      t.timestamps
    end
  end
end
