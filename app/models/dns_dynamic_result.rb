# == Schema Information
#
# Table name: dns_dynamic_results
#
#  id         :integer          not null, primary key
#  server     :string(255)
#  url        :string(255)
#  delay      :float
#  uuid       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DnsDynamicResult < ActiveRecord::Base
  attr_accessible :delay, :server, :url, :uuid, :schedule_uuid
end
