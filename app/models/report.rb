# == Schema Information
#
# Table name: reports
#
#  id         :integer          not null, primary key
#  user       :string(255)
#  uuid       :string
#  timestamp  :datetime
#  agent_type :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Report < ActiveRecord::Base
  attr_accessible :agent_type, :timestamp, :user, :uuid
end
