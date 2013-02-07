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
    Yell.new(:gelf).info 'Envio de parâmetros iniciado.',
                         '_schedule_id' => self.id
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
    self.uuid ||= SecureRandom.uuid.tr('-','')
  end

end
