class AddMissingFks < ActiveRecord::Migration
  def change
    add_foreign_key :compliances, :schedules, dependent: :delete
    add_foreign_key :compliances, :thresholds, dependent: :delete
    add_foreign_key :medians, :schedules, dependent: :delete
    add_foreign_key :medians, :thresholds, dependent: :delete
    add_foreign_key :results, :schedules, dependent: :delete
    add_foreign_key :results, :metrics, dependent: :delete
    add_foreign_key :kpis, :schedules, dependent: :delete
    add_foreign_key :kpis, :probes, :name => "kpis_destination_id_fk", :column => "destination_id"

  end
end
