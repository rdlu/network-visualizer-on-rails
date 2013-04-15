class AddDnsFieldsToDynamicResults < ActiveRecord::Migration
  def change
    add_column :dynamic_results, :dns_efic, :float
    add_column :dynamic_results, :dns_timeout_errors, :integer
    add_column :dynamic_results, :dns_server_failure_errors, :integer
  end
end
