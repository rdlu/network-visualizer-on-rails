require 'xmlsimple'

class Profile < ActiveRecord::Base
  attr_accessible :config_method, :config_parameters, :name, :connection_profile_id, :metric_ids, :nameservers, :sites
  attr_accessible :type_test, :source_probe, :timeout, :probe_size, :train_count, :metrics, :train_len, :time, :interval

  #validates
  validates :interval, :presence => true, :numericality => {:only_integer => true}
  validates :train_len, :presence => true, :numericality => {:only_integer => true}
  validates :timeout, :presence => true, :numericality => {:only_integer => true}
  validates :probe_size, :presence => true, :numericality => {:only_integer => true}

  #relationships
  belongs_to :connection_profile
  has_and_belongs_to_many :metrics
  has_many :schedules, :through => :evaluations

  accepts_nested_attributes_for :metrics

  def timeout
      h = load_hash_from_xml
      h['timeout']
  end

  def timeout=(t)
  end

  def probe_size
      h = load_hash_from_xml
      h['probe-size']
  end

  def probe_size=(t)
  end

  def type_test
      nil
  end

  def type_test=(t)
  end

  def source_probe
      h = load_hash_from_xml
      p = Probe.where(id: h['agt-index'])
      p
  end

  def source_probe=(t)
      # t eh a id de uma probe
  end

  def probe_size
      h = load_hash_from_xml
      h['probe-size']
  end

  def probe_size=(t)
  end

  def train_count
      h = load_hash_from_xml
      h['train-count']
  end

  def train_count=(t)
  end

  def train_len
      h = load_hash_from_xml
      h['train-len']
  end

  def train_len=(t)
  end

  def time
      h = load_hash_from_xml
  end

  def time=(t)
  end

  def interval
      h = load_hash_from_xml
  end

  def interval=(t)
  end

  def nameservers=(ns)
    # if config_parameters is empty, build it. Otherwise, leave it alone
    self.config_parameters ||= {nameservers: [], urls: []}.to_json
    # decode current config_parameters into a hash
    cfg_params = ActiveSupport::JSON.decode(self.config_parameters)
    # set just the nameservers key to the new array
    cfg_params["nameservers"] = ns
    # and update config_parameters with the new hash
    self.config_parameters = cfg_params.to_json
  end

  def nameservers
      a = ActiveSupport::JSON.decode(self.config_parameters)["nameservers"]
      if a
        a
      else
        []
      end
  end

  def sites=(sis)
    # if config_parameters is empty, build it. Otherwise, leave it alone
    self.config_parameters ||= {nameservers: [], urls: []}.to_json
    # decode current config_parameters into a hash
    cfg_params = ActiveSupport::JSON.decode(self.config_parameters)
    # set just the urls key to the new array
    cfg_params["urls"] = sis
    # and update config_parameters with the new hash
    self.config_parameters = cfg_params.to_json
  end

  def sites
    a =ActiveSupport::JSON.decode(self.config_parameters)["urls"]
    if a
      a
    else
      []
    end
  end

  private

  def load_hash_from_xml
      XmlSimple.xml_in(self.config_parameters, { 'KeepRoot' => true }) if self.config_method == "raw_xml" else {}
  end

  def save_xml_from_hash(h)
    self.config_parameters = XmlSimple.xml_out(h, { 'KeepRoot' => true }) if self.config_method == "raw_xml"
  end
end
