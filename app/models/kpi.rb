class Kpi < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :destination, :class_name => 'Probe', :foreign_key => 'destination_id'
  belongs_to :source, :class_name => 'Probe', :foreign_key => 'source_id'
  attr_accessible :brand, :cell_id, :change_of_ips, :conn_tech, :conn_type, :destination_name, :dns_latency, :error_rate, :lac, :model, :mtu, :route, :signal, :source_name, :timestamp, :uuid
end
