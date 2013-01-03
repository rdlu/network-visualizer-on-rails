class Entity < ActiveRecord::Base
  # attr_accessible :title, :body

  attr_accessible :name, :ipadress, :description, :polling, :status, :type, :zip, :adress, :adressnum,
                  :district, :city, :state, :latitude, :longitude, :isAndroid


  validates :name, :presence => true, :length => {:maximum => 255, :minimum => 3}, :format => { :width => %r{^[0-9a-zA-Z]+$} },
            :uniqueness => true
  validates :ipadress , :presence => true, :length => {:maximum => 255, :minimum => 7},:uniqueness => true,
            #:format => { :width => %r{^(([a-zA-Z0-9\-_]*[a-zA-Z0-9_])\.)*([A-Za-z]|[A-Za-z_][A-Za-z0-9\-]*[A-Za-z0-9_])$}},
            :if => self.ipOrHostname
  #validates :polling
  validates :status, :presence => true, :inclusion => { :in => [-1, 3] }
  validates :type
  validates :zip
  validates :adress
  validates :adressum
  validates :district
  validates :city, :presence => true, :length => {:maximum => 255, :minimum => 3},
            :format => { :width => %r{^[0-9a-zA-Z]+$} }

  validates :state
  validates :latitude, :format =>{ :width => %r{^([-]?[0-9]{1,3}[.][0-9]+)|([-]?[0-9]{1,3})$}}
  validates :longitude, :format =>{ :width => %r{^([-]?[0-9]{1,2}[.][0-9]+)|([-]?[0-9]{1,2})$}}
  validates :isAndroid, :presence => true, :inclusion => { :in => [0, 1] }


  def ipOrHostname
     if ip(self.ipadress)  || hostname((self.ipadress))
       return true
     else
       return false
     end
  end

  def ip
      if IPAddress.valid? self.ipadress
        return true
      else
        return false
      end
  end

  def hostname
      #^(([a-zA-Z0-9\-_]*[a-zA-Z0-9_])\.)*([A-Za-z]|[A-Za-z_][A-Za-z0-9\-]*[A-Za-z0-9_])$
  end

end
