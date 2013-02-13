# coding: utf-8
class Schedule < ActiveRecord::Base
  before_save :default_values
  attr_accessible :end, :polling, :start, :status, :destination_id, :source_id, :profile_ids

  has_many :evaluations
  has_many :profiles, :through => :evaluations
  accepts_nested_attributes_for :profiles
  belongs_to :destination, :class_name => 'Probe', :foreign_key => 'destination_id'
  belongs_to :source, :class_name => 'Probe', :foreign_key => 'source_id'

  validates_presence_of :destination_id, :source_id

  def setup
    Yell.new(:gelf, :facility => 'netmetric').info 'Envio de parametros iniciado!',
                                                   '_schedule_id' => self.id
    self.profiles.each do |profile|
      require profile.config_method+'_job'
      Kernel.const_get((profile.config_method+'_job').camelize.to_sym).profile_setup(profile, self)
    end

    #TODO: tornar o carregamento da agenttable e managertable dinamico, quando tivermos a especificacao
    SnmpLegacyJob::agent_setup profiles, self
    SnmpLegacyJob::manager_setup profiles, self

    self.status = 'active'
    self.save
    Yell.new(:gelf, :facility => 'netmetric').info 'Envio de agenda de testes concluida!',
                                                   '_schedule_id' => self.id, '_probe_id' => self.destination.id
  end

  def allocated_profiles
    profiles = []
    if self.destination
      self.destination.schedules do |schedule|
        profiles += schedule.profiles
      end
    end

    profiles.uniq
  end

  def default_values
    self.status ||= 'config'
    self.start ||= DateTime.now
    self.end ||= DateTime.now.advance(:years => +2).at_midnight
    self.uuid ||= SecureRandom.uuid.tr('-', '')
  end

end
