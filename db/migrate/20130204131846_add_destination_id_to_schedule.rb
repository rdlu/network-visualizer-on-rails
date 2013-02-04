class AddDestinationIdToSchedule < ActiveRecord::Migration
  def change
    remove_foreign_key 'schedules', 'probes'
    remove_column :schedules, :probe_id

    change_table :schedules do |t|
      t.references :destination
      t.references :source
    end

    add_foreign_key 'schedules', 'probes', :name => 'schedules_destination_id_fk', :column => 'destination_id'
    add_foreign_key 'schedules', 'probes', :name => 'schedules_source_id_fk', :column => 'source_id'
  end
end
