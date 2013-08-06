# == Schema Information
#
# Table name: kpis
#
#  id               :integer          not null, primary key
#  schedule_uuid    :string
#  uuid             :string
#  destination_id   :integer
#  source_id        :integer
#  schedule_id      :integer
#  timestamp        :timestamp(6)
#  source_name      :string(255)
#  destination_name :string(255)
#  lac              :string(255)
#  cell_id          :string(255)
#  brand            :string(255)
#  model            :string(255)
#  conn_type        :string(255)
#  conn_tech        :string(255)
#  signal           :string(255)
#  error_rate       :string(255)
#  change_of_ips    :integer
#  mtu              :integer
#  dns_latency      :integer
#  route            :text
#  created_at       :timestamp(6)     not null
#  updated_at       :timestamp(6)     not null
#

class Kpi < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :destination, :class_name => 'Probe', :foreign_key => 'destination_id'
  belongs_to :source, :class_name => 'Probe', :foreign_key => 'source_id'
  attr_accessible :brand, :cell_id, :change_of_ips, :conn_tech, :conn_type, :destination_name, :dns_latency, :error_rate, :lac, :model, :mtu, :route, :signal, :source_name, :timestamp, :uuid

  def timestamp= value
    if value.is_a? Date
      self[:timestamp] = value.to_datetime
    else
      #converte do formato UNIX TIMESTAMP
      self[:timestamp] = DateTime.strptime(value, '%s')
    end
  end
end
