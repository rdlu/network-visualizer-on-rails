class Schedule < ActiveRecord::Base
  attr_accessible :end, :polling, :start, :status, :destination_id, :source_id

  has_many :evaluations
  has_many :profiles, :through => :evaluations
  belongs_to :destination, :class_name => 'Probe', :foreign_key => 'destination_id'
  belongs_to :source, :class_name => 'Probe', :foreign_key => 'source_id'

  def setup

  end

  def allocated_test_profiles
    tests = []
    if self.destination
      self.destination.schedules do |schedule|
        tests += schedule.profiles
      end
    end

    tests
  end

end
