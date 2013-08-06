# == Schema Information
#
# Table name: dynamic_results
#
#  id                        :integer          not null, primary key
#  rtt                       :float
#  throughput_udp_down       :float
#  throughput_udp_up         :float
#  throughput_tcp_down       :float
#  throughput_http_down      :float
#  throughput_http_up        :float
#  jitter_down               :float
#  jitter_up                 :float
#  loss_down                 :float
#  loss_up                   :float
#  pom_down                  :integer
#  pom_up                    :integer
#  uuid                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  dns_efic                  :float
#  dns_timeout_errors        :integer
#  dns_server_failure_errors :integer
#  user                      :string(255)
#

class DynamicResult < ActiveRecord::Base
  attr_accessible :jitter_down, :jitter_up, :loss_down, :loss_up, :pom_down, :pom_up, :rtt, :throughput_http_down, :throughput_http_up, :throughput_tcp_down, :throughput_udp_down, :throughput_udp_up, :throughput_udp_up, :uuid, :schedule_uuid
end
