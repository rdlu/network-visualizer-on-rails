class AddOsversionToProbe < ActiveRecord::Migration
  def change
    add_column :probes, :osversion, :string
  end
end
