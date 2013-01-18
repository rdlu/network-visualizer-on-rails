class Entity < ActiveRecord::Base

  has_many :processes_as_source, :class_name => "Processes", :foreign_key => "source_id"
  has_many :processes_as_destination, :class_name => "Processes", :foreign_key => "destination_id"
  has_many :destinations, :class_name => "Entity", :through => :processes, :foreign_key => "source_id"
  has_many :sources, :class_name => "Entity", :through => :processes, :foreign_key => "destination_id"

  attr_accessible :name, :ipadress, :description, :polling, :status, :type, :zip, :adress, :adressnum,
                  :district, :city, :state, :latitude, :longitude, :isAndroid


  validates :name, :presence => true, :length => {:maximum => 255, :minimum => 3}, :format => { :width => %r{^[0-9a-zA-Z]+$} },
            :uniqueness => true
  validates :ipadress , :presence => true, :length => {:maximum => 255, :minimum => 7},:uniqueness => true,
            :if => ipOrHostname?
  validates :polling, :if => polling?
  validates :status, :presence => true, :inclusion => { :in => [-1, 3] }
  validates :city, :presence => true, :length => {:maximum => 255, :minimum => 3},
            :format => { :width => %r{^[0-9a-zA-Z]+$} }
  validates :latitude, :format =>{ :width => %r{^([-]?[0-9]{1,3}[.][0-9]+)|([-]?[0-9]{1,3})$}}
  validates :longitude, :format =>{ :width => %r{^([-]?[0-9]{1,2}[.][0-9]+)|([-]?[0-9]{1,2})$}}
  validates :isAndroid, :presence => true, :inclusion => { :in => [0, 1] }

  protected

  def ipOrHostname?
     if ip(self.ipadress)  || hostname(self.ipadress)
        true
     else
        false
     end
  end

  def ip(ip="")
      if IPAddress.valid? ip
         true
      else
         false
      end
  end

  def hostname(adress="")
    (adress =~ /^(([a-zA-Z0-9\-_]*[a-zA-Z0-9_])\.)*([A-Za-z]|[A-Za-z_][A-Za-z0-9\-]*[A-Za-z0-9_])$/)
  end

  def polling?
    minWait = 300000 #300 secs
    self.polling * 1000 >= minWait
  end

end
