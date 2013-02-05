class RenameTestToEvaluation < ActiveRecord::Migration
  def up
    rename_table :tests, :evaluations
  end

  def down
    rename_table :evaluations, :tests
  end
end
