class RenameQuotientToCompliance < ActiveRecord::Migration
  def up
    rename_table :quotients, :compliances
  end

  def down
    rename_table :compliances, :quotients
  end
end
