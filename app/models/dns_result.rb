class DnsResult < ActiveRecord::Base
  attr_accessible :delay, :server, :url, :uuid, :status
end
