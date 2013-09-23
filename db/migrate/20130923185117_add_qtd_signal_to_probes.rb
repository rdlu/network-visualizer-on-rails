class AddQtdSignalToProbes < ActiveRecord::Migration
  def change
    add_column :probes, :signal, :integer
  end
end
