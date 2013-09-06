# == Schema Information
#
# Table name: web_load_dynamic_results
#
#  id         :integer          not null, primary key
#  url        :string(255)
#  time       :float
#  size       :float
#  throughput :float
#  uuid       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WebLoadDynamicResult < ActiveRecord::Base
  attr_accessible :size, :throughput, :time, :url, :uuid, :schedule_uuid, :timestamp
end
