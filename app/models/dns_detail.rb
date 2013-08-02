class DnsDetail < ActiveRecord::Base
  attr_accessible :average, :efic, :server_failure_errors, :timeout_errors, :uuid, :schedule_uuid
end
