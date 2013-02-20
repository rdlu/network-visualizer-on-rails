# coding: utf-8
class Probe < ActiveRecord::Base
  before_save :default_values
  attr_accessible :address, :description, :ipaddress, :latitude, :longitude, :name, :pre_address, :status, :type, :city, :state,
                  :connection_profile_id, :plan_id

  #validacao
  validates :name, :presence => true, :length => {:maximum => 255, :minimum => 3}, :format => { :with => %r{^[0-9a-zA-Z][0-9a-zA-Z\-\_]+[0-9a-zA-Z]$} },
            :uniqueness => true
  validates :ipaddress , :presence => true, :length => {:maximum => 255, :minimum => 3}, :uniqueness => true
  validate :validate_ipaddress
  #validates :polling, :if => :polling?
  validates :status, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => -1, :less_than_or_equal_to => 3 }
  validates :latitude, :format => { :with => %r{^([-]?[0-9]{1,3}[.][0-9]+)|([-]?[0-9]{1,3})$} }
  validates :longitude, :format => { :with => %r{^([-]?[0-9]{1,2}[.][0-9]+)|([-]?[0-9]{1,2})$} }
  validates :city, :presence => true
  validates :state, :presence => true

  @inheritance_column = 'type2'

  #relationships
  belongs_to :plan
  belongs_to :connection_profile
  has_many :destinations, :through => :schedules
  has_many :sources, :through => :schedules_as_source
  has_many :schedules, :foreign_key => 'destination_id'
  has_many :schedules_as_source, :class_name => :schedule, :foreign_key => 'source_id'

  #escopos de pesquisa
  scope :active, where(:status => 1)
  scope :by_city, proc { |city| where(:city => city)}
  scope :by_state, proc { |state| where(:state => state)}
  scope :by_type, proc { |type| where(:type => type)}

  #destinos retornava a si mesmo sempre, removendo
  def destinations
    arr = super
    arr - [self]
  end

  def pretty_name
    "#{self.name} (#{self.ipaddress})"
  end

  def pretty_name_with_location
    "#{self.name} (#{self.ipaddress}) - #{self.city}/#{self.state.upcase}"
  end

  def real_ipaddress
    if self.hostname? self.ipaddress
      require 'resolv'
      return Resolv::DNS.new(:nameserver => ['143.54.85.34'], :search => ['vivo.com.br'], :ndots => 1).getaddress(self.ipaddress)
    end
    return self.ipaddress if IPAddress.valid? self.ipaddress
    false
  end


  #funcoes custom de validacao

  def validate_ipaddress
    errors.add(:ipaddress,' tem um formato inválido') unless ip_or_hostname?
  end

  def ip_or_hostname?
    teste1 = IPAddress.valid? self.ipaddress
    teste2 = hostname?(self.ipaddress)
    teste2 || teste1
  end

  def hostname?(address='')
    !!(address.match(/^(([a-zA-Z0-9\-_]*[a-zA-Z0-9_])\.)*([A-Za-z]|[A-Za-z_][A-Za-z0-9\-]*[A-Za-z0-9_])$/))
  end

  def polling?
    min_wait = 300000 #300 secs
    self.polling * 1000 >= min_wait
  end

  private

  def default_values
    self.status ||= 1
  end
end
