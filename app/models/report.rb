class Report < ActiveRecord::Base
  attr_accessible :agent_type, :timestamp, :user, :uuid
end
