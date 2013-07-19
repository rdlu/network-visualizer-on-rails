class AddAnatelToProbe < ActiveRecord::Migration
  def change
    add_column :probes, :anatel, :boolean
  end
end
