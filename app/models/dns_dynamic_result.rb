class DnsDynamicResult < ActiveRecord::Base
  attr_accessible :delay, :server, :url, :uuid, :schedule_uuid
end
