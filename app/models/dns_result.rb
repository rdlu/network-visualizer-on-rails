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
  belongs_to :schedule
  
  attr_accessible :delay, :server, :url, :uuid, :status, :schedule_uuid, :timestamp, :schedule_id

  validates :status, presence: true, format: {with: %r{^[A-Z0-9]+$}}
  validates :server, presence: true

  validate :validate_serveraddress

  scope :by_sites, lambda { |sites|
    where(url: sites) unless sites == '' or sites[0] == ''
  }

  scope :by_dns, lambda { |dns|
    where(server: dns) unless dns == '' or dns[0] == ''
  }

  scope :by_server, lambda { |dns|
    where(server: dns) unless dns == '' or dns[0] == ''
  }

  def validate_serveraddress
    errors.add(:server, ' tem um formato inválido') unless IPAddress.valid? self.server
  end

  def timestamp= value
    if value.is_a? Date
      self[:timestamp] = value.to_datetime
    else
      #converte do formato UNIX TIMESTAMP
      self[:timestamp] = DateTime.strptime(value, '%s')
    end
  end

  def self.possible_status
    %w(OK NXDOMAIN FORMERR SERVFAIL TIMEOUT REFUSED OTHER)
  end

end
