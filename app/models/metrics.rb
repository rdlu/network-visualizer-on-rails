class Metrics < ActiveRecord::Base

  belongs_to :profile

  has_many :processes, :through => :metrics_processes
  has_many :thresholdvalues
  has_many :thressholdprofiles, :through => :thresholdvalues

  attr_accessible :name, :plugin, :desc, :profile_id, :reverse, :order

  validates :name, :presence => true, :length => {:maximum => 20, :minimum => 3} #, :if => metricAvailable?
  validates :plugin, :presence => true, :length => {:maximum => 20, :minimum => 3} #, :if => pluginAvailable?


end
