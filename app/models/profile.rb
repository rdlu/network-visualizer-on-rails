class Profile < ActiveRecord::Base
  # attr_accessible :title, :body

  #belongs_to
  #has_many

  attr_accessible :name, :count,:probeCount, :probeSize, :gap, :qosType, :qosValue, :timeout,
                  :protocol, :description, :status, :polling

  validates :name, :presence => true, :length => {:maximum => 32, :minimun => 3}, :format => { :width => %r{^[0-9a-zA-Z]+$} }
  validates :count, :presence => true, :format => {:width => %r{^[0-9]+$} }
  validates :probeCount, :presence => true, :format => {:width => %r{^[0-9]+$} }
  validates :probeValue, :presence => true, :format => {:width => %r{^[0-9]+$} }
  validates :gap, :presence => true, :format => {:width => %r{^[0-9]+$} }
  validates :qosType, :presence => true, :format => {:width => %r{^[0-9]+$} }
  validates :qosValue, :presence => true, :format => {:width => %r{^[0-9]+$} }
  validates :timeout, :presence => true, :format => {:width => %r{^[0-9]+$} }





end
