class Schedule < ActiveRecord::Base
  attr_accessible :end, :polling, :start, :status, :probe_id

  belongs_to :probe
  has_many :tests

  def setup

  end

end
