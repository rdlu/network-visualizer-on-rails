class AddAgentVersionToProbes < ActiveRecord::Migration
  def change
    add_column :probes, :agent_version, :string
  end
end
