class Metrics < ActiveRecord::Base

  belongs_to :profile

  has_many :processes, :through => :metrics_processes, :foreign_key => "process_id"
  has_many :thresholdvalues
  has_many :thressholdprofiles, :through => :thresholdvalues, :foreign_key =>"thresholdprofile_id"

  attr_accessible :name, :plugin, :desc, :profile_id, :reverse, :order

  validates :name, :presence => true, :length => {:maximum => 20, :minimum => 3}, :if => nameAvailable?
  validates :plugin, :presence => true, :length => {:maximum => 20, :minimum => 3}, :if => pluginAvailable?

  protected

  def nameAvailable?
  #verificar se 'name' está carregado no banco
    true
  end

  def pluginAvailable?
  #verificar se 'plugin' está carregado no banco
    true
  end

end
