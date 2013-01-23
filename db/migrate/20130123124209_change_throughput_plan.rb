class ChangeThroughputPlan < ActiveRecord::Migration
  def change
    add_column :plans, :throughputUp, :integer
    rename_column :plans, :throughput, :throughputDown
  end
end
