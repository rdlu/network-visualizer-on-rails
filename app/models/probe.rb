class Probe < ActiveRecord::Base
  attr_accessible :address, :description, :ipaddress, :latitude, :longitude, :name, :pre_address, :status, :type, :city, :state,
                  :connection_profile_id, :plan_id

  #validacao
  validates :name, :presence => true, :length => {:maximum => 255, :minimum => 3}, :format => { :with => %r{^[0-9a-zA-Z]+$} },
            :uniqueness => true
  validates :ipaddress , :presence => true, :length => {:maximum => 255, :minimum => 7},:uniqueness => true,
            :if => :ip_or_hostname?
  #validates :polling, :if => :polling?
  validates :status, :presence => true, :inclusion => { :in => [-1, 3] }
  validates :latitude, :format => { :with => %r{^([-]?[0-9]{1,3}[.][0-9]+)|([-]?[0-9]{1,3})$} }
  validates :longitude, :format => { :with => %r{^([-]?[0-9]{1,2}[.][0-9]+)|([-]?[0-9]{1,2})$} }

  #relationships
  belongs_to :plan
  belongs_to :connection_profile

  #escopos de pesquisa
  scope :active, where(:status => 1)
  scope :by_city, proc { |city| where(:city => city)}
  scope :by_state, proc { |state| where(:state => state)}
  scope :by_type, proc { |type| where(:type => type)}


  #funcoes custom de validacao
  protected

  def ip_or_hostname?
    IPAddress.valid? ipaddress || hostname(ipaddress)
  end

  def hostname(address="")
    address =~ /^(([a-zA-Z0-9\-_]*[a-zA-Z0-9_])\.)*([A-Za-z]|[A-Za-z_][A-Za-z0-9\-]*[A-Za-z0-9_])$/
  end

  def polling?
    min_wait = 300000 #300 secs
    self.polling * 1000 >= min_wait
  end
end
