class Processes < ActiveRecord::Base

  has_many :metrics, :through => :metrics_processes
  belongs_to :thresholdProfile, :foreing_key => "threshold_id"

  attr_accessible :added,:updated, :status, :profile_id, :source_id, :destination_id, :threshold_id

  validates :added, :presence => true
  validates :updated, :presence => true
  validates :status, :presence => true
  validates :profile_id, :presence => true
  validates :source_id, :presence => true
  validates :destination_id, :presence => true
  validates :threshold_id, :presence => true


end
