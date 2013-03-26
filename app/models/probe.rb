# coding: utf-8
class Probe < ActiveRecord::Base
  before_save :default_values
  attr_accessible :address, :description, :ipaddress, :latitude, :longitude, :name, :pre_address, :status, :type, :city, :state,
                  :connection_profile_id, :plan_id

  #validacao
  validates :name, :presence => true, :length => {:maximum => 255, :minimum => 3}, :format => {:with => %r{^[0-9a-zA-Z][0-9a-zA-Z\-\_]+[0-9a-zA-Z]$}},
            :uniqueness => true
  validates :ipaddress, :presence => true, :length => {:maximum => 255, :minimum => 3}, :uniqueness => true
  validate :validate_ipaddress
  #validates :polling, :if => :polling?
  validates :status, :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => -1, :less_than_or_equal_to => 3}
  validates :latitude, :format => {:with => %r{^([-]?[0-9]{1,3}[.][0-9]+)|([-]?[0-9]{1,3})$}}
  validates :longitude, :format => {:with => %r{^([-]?[0-9]{1,2}[.][0-9]+)|([-]?[0-9]{1,2})$}}
  validates :city, :presence => true
  validates :state, :presence => true

  @inheritance_column = 'type2'

  #relationships
  belongs_to :plan
  belongs_to :connection_profile
  has_many :destinations, :through => :schedules_as_source
  has_many :sources, :through => :schedules
  #as duas proximas abaixo sao equivalentes
  has_many :schedules, :foreign_key => 'destination_id'
  has_many :schedules_as_destination, :class_name => Schedule, :foreign_key => 'destination_id'
  has_many :schedules_as_source, :class_name => Schedule, :foreign_key => 'source_id'

  #escopos de pesquisa
  scope :active, where(:status => 1)
  scope :by_city, proc { |city| where(:city => city) }
  scope :by_state, proc { |state| where(:state => state) }
  scope :by_type, proc { |type| where(:type => type) }

  def pretty_name
    "#{self.name} (#{self.ipaddress})"
  end

  def pretty_status
    case self.status
      when 0
        "inactive"
      when 1
        "active"
      when 2
        "attention"
      when 3
        "error"
    end
  end

  def pretty_name_with_location
    "#{self.name} (#{self.ipaddress}) - #{self.city}/#{self.state.upcase}"
  end

  def real_ipaddress
    if self.hostname? self.ipaddress
      require 'resolv'
      return Resolv::DNS.new(:nameserver => ['143.54.85.34'], :search => ['vivo.com.br'], :ndots => 1).getaddress(self.ipaddress).to_s
    end
    return self.ipaddress if IPAddress.valid? self.ipaddress
    false
  end

  def metrics (source = self.sources.at(0), sort_by = :order)
    metrics = []
    self.schedules.where(:source_id => source.id).each do |schedule|
      metrics += schedule.metrics
    end
    metrics.uniq.sort_by{ |metric| metric[sort_by]}
  end

  def thresholds (source = self.sources.at(0), sort_by = :name)
    metrics = self.metrics(source)
    thresholds = []
    metrics.each do |metric|
      thresholds += metric.thresholds
    end
    thresholds.uniq.sort_by{ |threshold| threshold[sort_by]}
  end


  #funcoes custom de validacao

  def validate_ipaddress
    errors.add(:ipaddress, ' tem um formato inválido') unless ip_or_hostname?
  end

  def ip_or_hostname?
    teste1 = IPAddress.valid? self.ipaddress
    teste2 = hostname?(self.ipaddress)
    teste2 || teste1
  end

  def hostname?(address='')
    !!(address.match(/^(?=.{1,255}$)[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?(?:\.[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?)*\.?$/))
  end

  def polling?
    min_wait = 300000 #300 secs
    self.polling * 1000 >= min_wait
  end

  def self.types
    [%w(Android android),
     %w(Linux linux)]
  end

  def self.states
    [
      ["Acre", "ac"],
      ["Alagoas", "al"],
      ["Amapá", "ap"],
      ["Amazonas", "am"],
      ["Bahia", "ba"],
      ["Ceará", "ce"],
      ["Distrito Federal", "df"],
      ["Espirito Santo", "es"],
      ["Goiás", "go"],
      ["Maranhão", "ma"],
      ["Mato Grosso", "mt"],
      ["Mato Grosso do Sul", "ms"],
      ["Minas Gerais", "mg"],
      ["Pará", "pa"],
      ["Paraíba", "pb"],
      ["Pernambuco", "pe"],
      ["Piauí", "pi"],
      ["Rio de Janeiro","rj"],
      ["Rio Grande do Norte", "rn"],
      ["Rio Grande do Sul","rs"],
      ["Rondônia", "ro"],
      ["Roraima", "rr"],
      ["Santa Catarina", "sc"],
      ["São Paulo","sp"],
      ["Sergipe", "se"],
      ["Tocantins", "to"]
    ]
  end

  private

  def default_values
    self.status ||= 1
  end
end
