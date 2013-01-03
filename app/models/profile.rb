class Profile < ActiveRecord::Base
  # attr_accessible :title, :body

  #belongs_to

  has_many :processes #, :metrics

  before_save :set_default

  attr_accessible :name, :count,:probeCount, :probeSize, :gap, :qosType, :qosValue, :timeout,
                  :protocol, :description, :status, :polling

  validates :name, :presence => true, :length => {:maximum => 32, :minimum => 3}, :format => { :width => %r{^[0-9a-zA-Z]+$} }
  validates :count, :probeCount, :probeValue, :gap, :timeout, :polling, :presence => true, :format => {:width => %r{^[0-9]+$} }
  #validates :probeCount, :presence => true, :format => {:width => %r{^[0-9]+$} }
  #validates :probeValue, :presence => true, :format => {:width => %r{^[0-9]+$} }
  #validates :gap, :presence => true, :format => {:width => %r{^[0-9]+$} }
  #validates :timeout, :presence => true, :format => {:width => %r{^[0-9]+$} }
  #validates :polling , :presence => true, :format => {:width => %r{^[0-9]+$} }
  validates :protocol, :presence => true, :inclusion => { :in => [0, 1] }
  validates :qosType, :presence => true, :inclusion => { :in => [0, 1] }
  validates :qosValue, :presence => true,:inclusion => { :in => [0, 8192] }

  protected

  def set_default
    self.qosValue = 0 unless self.qosValue
    self.qosType = 0 unless self.qosType
    self.timeout = 300 unless self.timeout
  end

end
