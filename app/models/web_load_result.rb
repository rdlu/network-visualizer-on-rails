# == Schema Information
#
# Table name: web_load_results
#
#  id                      :integer          not null, primary key
#  url                     :string(255)
#  time                    :float
#  size                    :integer
#  throughput              :float
#  time_main_domain        :float
#  size_main_domain        :integer
#  throughput_main_domain  :float
#  time_other_domain       :float
#  size_other_domain       :integer
#  throughput_other_domain :float
#  uuid                    :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class WebLoadResult < ActiveRecord::Base
  attr_accessible :size, :size_main_domain, :size_other_domain, :throughput, :throughput_main_domain, :throughput_other_domain, :time, :time_main_domain, :time_other_domain, :url, :uuid, :schedule_uuid, :timestamp
end
