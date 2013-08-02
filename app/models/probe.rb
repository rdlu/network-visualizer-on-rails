# coding: utf-8
class Probe < ActiveRecord::Base
  before_save :default_values
  attr_accessible :address, :description, :ipaddress, :latitude, :longitude, :name, :pre_address, :status, :type, :city, :state, :connection_profile_id, :plan_id, :areacode, :agent_version, :anatel, :pop,:bras, :osversion, :modem

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
  scope :is_anatel, proc { |anatel| where(:anatel => anatel)}
  scope :by_pop, proc { |pop| where(:pop => pop) }
  scope :by_modem, proc { |modem| where(:modem => modem) }
  scope :by_tech, lambda { |tech|
    joins(:connection_profile).where('connection_profiles.name_id' => tech)
  }

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

  def status_color
    case self.status
      when 0
        "gray"
      when 1
        "green"
      when 2
        "yellow"
      when 3
        "red"
    end
  end

  def pretty_name_with_location
    "#{self.name} (#{self.ipaddress}) - #{self.city}/#{self.state.upcase}"
  end

  def real_ipaddress
    return self.ipaddress if IPAddress.valid? self.ipaddress
    if self.hostname? self.ipaddress
      require 'resolv'
      begin
         return Resolv::DNS.new(:nameserver => ['143.54.85.34'], :search => ['vivo.com.br'], :ndots => 1).getaddress(self.ipaddress).to_s
      rescue
        return "DNS não resolvido."
      end
    end
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

  def self.techs
    arr = []
    ConnectionProfile.all.each do |connprofile|
      arr << connprofile.name_id
    end
    arr
  end

  def self.modems
      $redis.smembers "Probe:Modems"
  end

  def self.pops
      $redis.smembers "Probe:Pops"
  end

  def self.add_modem(modem)
      $redis.sadd 'Probe:Modems', modem
  end

  def self.add_pop(pop)
      $redis.sadd 'Probe:Pops', pop
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
      ["Paraná","pr"],
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

  def self.cod_area
    [
        ['AC',68],
        ['AL',82],
        ['AP',96],
        ['AM',92],
        ['AM',97],
        ['BA',71],
        ['BA',73],
        ['BA',74],
        ['BA',75],
        ['BA',77],
        ['CE',85],
        ['CE',88],
        ['DF',61],
        ['ES',27],
        ['ES',28],
        ['GO',62],
        ['GO',64],
        ['MA',98],
        ['MA',99],
        ['MT',65],
        ['MT',66],
        ['MS',67],
        ['MG',31],
        ['MG',32],
        ['MG',33],
        ['MG',34],
        ['MG',35],
        ['MG',37],
        ['MG',38],
        ['PA',91],
        ['PA',93],
        ['PA',94],
        ['PB',83],
        ['PR',41],
        ['PR',42],
        ['PR',43],
        ['PR',44],
        ['PR',45],
        ['PR',46],
        ['PE',81],
        ['PE',87],
        ['PI',86],
        ['PI',89],
        ['RJ',21],
        ['RJ',22],
        ['RJ',24],
        ['RN',84],
        ['RS',51],
        ['RS',53],
        ['RS',54],
        ['RS',55],
        ['RO',95],
        ['RR',69],
        ['SC',47],
        ['SC',48],
        ['SC',49],
        ['SP',11],
        ['SP',12],
        ['SP',13],
        ['SP',14],
        ['SP',15],
        ['SP',16],
        ['SP',17],
        ['SP',18],
        ['SP',19],
        ['SE',79],
        ['TO',63]

    ]
  end

  private

  def default_values
    self.status ||= 1
  end

end
