class AddPopBrasToProbe < ActiveRecord::Migration
  def change
    add_column :probes, :pop, :string
    add_column :probes, :bras, :string
  end
end
