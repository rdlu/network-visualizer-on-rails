class DnsResult < ActiveRecord::Base
  attr_accessible :delay, :server, :url, :uuid, :status, :schedule_uuid
end
