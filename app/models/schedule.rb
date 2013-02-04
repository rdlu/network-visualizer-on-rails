class Schedule < ActiveRecord::Base
  attr_accessible :end, :polling, :start, :status, :destination_id, :source_id

  belongs_to :destination, :class_name => 'Probe', :foreign_key => 'destination_id'
  belongs_to :source, :class_name => 'Probe', :foreign_key => 'source_id'
  has_many :tests
  has_many :test_profiles, :through => :tests

  def setup

  end

end
