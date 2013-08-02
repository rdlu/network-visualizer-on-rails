class DynamicResult < ActiveRecord::Base
  attr_accessible :jitter_down, :jitter_up, :loss_down, :loss_up, :pom_down, :pom_up, :rtt, :throughput_http_down, :throughput_http_up, :throughput_tcp_down, :throughput_udp_down, :throughput_udp_up, :throughput_udp_up, :uuid, :schedule_uuid
end
