# == Schema Information
#
# Table name: dns_results
#
#  id         :integer          not null, primary key
#  server     :string(255)
#  url        :string(255)
#  delay      :integer
#  uuid       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  status     :string(255)
#

class DnsResult < ActiveRecord::Base
  attr_accessible :delay, :server, :url, :uuid, :status, :schedule_uuid, :timestamp

  scope :by_sites, lambda { |sites|
    where(url: sites) unless sites == '' or sites[0] == ''
  }

  scope :by_dns, lambda { |dns|
    where(server: dns) unless dns == '' or dns[0] == ''
  }

  scope :by_server, lambda { |dns|
    where(server: dns) unless dns == '' or dns[0] == ''
  }
end
