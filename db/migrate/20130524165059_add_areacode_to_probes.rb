class AddAreacodeToProbes < ActiveRecord::Migration
  def change
    add_column :probes, :areacode, :integer
  end
end
