class CreateThresholds < ActiveRecord::Migration
  def change
    create_table :thresholds do |t|
      #nome = scm4, scm5, smp10
      t.string :name
      #compliance = cumprimento da obrigacao, ex: 85% das vezes no mes ....
      t.float :compliance_level, :default => 0.85, :null => false
      t.string :compliance_period, :default => 'monthly', :null => false
      t.string :compliance_method, :default => 'standard', :null => false
      #goal = meta, ex: 2ms, 1mbps
      t.float :goal_level, :null => false
      t.string :goal_period, :default => 'daily', :null => false
      t.string :goal_method, :default => 'median', :null => false

      t.references :connection_profile
      t.references :metric

      t.timestamps
    end
  end
end
