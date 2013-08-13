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

require 'spec_helper'

describe DynamicResult do
  pending "add some examples to (or delete) #{__FILE__}"
end
