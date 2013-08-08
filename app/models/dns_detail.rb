# == Schema Information
#
# Table name: dns_details
#
#  id                    :integer          not null, primary key
#  efic                  :float
#  average               :float
#  timeout_errors        :integer
#  server_failure_errors :integer
#  uuid                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class DnsDetail < ActiveRecord::Base
  attr_accessible :average, :efic, :server_failure_errors, :timeout_errors, :uuid, :schedule_uuid
end
