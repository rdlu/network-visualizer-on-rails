class RenameThroughputVariablesOnPlan < ActiveRecord::Migration
  def change
    rename_column :plans, :throughputDown, :throughput_down
    rename_column :plans, :throughputUp, :throughput_up
  end
end
