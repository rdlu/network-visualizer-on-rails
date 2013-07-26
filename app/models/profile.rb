require 'xmlsimple'

class Profile < ActiveRecord::Base
  attr_accessible :config_method, :config_parameters, :name, :connection_profile_id, :metric_ids, :nameservers, :sites
  attr_accessible :type_test, :source_probe, :timeout, :probe_size, :train_count, :metrics, :train_len, :time, :interval, :metrics, :protocol, :mode

  #validates
=begin
  validates :interval, :presence => true, :numericality => {:only_integer => true}
  validates :train_len, :presence => true, :numericality => {:only_integer => true}
  validates :timeout, :presence => true, :numericality => {:only_integer => true}
  validates :probe_size, :presence => true, :numericality => {:only_integer => true}
=end

  #relationships
  belongs_to :connection_profile
  has_and_belongs_to_many :metrics
  has_many :schedules, :through => :evaluations

  accepts_nested_attributes_for :metrics

  #def metrics
  #    h = load_hash_from_xml
  #    Metric.where(plugin: h['NMAgent']['plugins'])
  #end

  #def metrics=(ms)
  #    h = load_hash_from_xml
  #    h['NMAgent']['plugins'] = ms
  #    save_xml_from_hash(ms)
  #end

  def manager_ip
      h = load_hash_from_xml
      h['NMAgent']['manager-ip']
  end

  def manager_ip=(m)
      h = load_hash_from_xml
      h['NMAgent']['manager-ip'] = m
      save_xml_from_hash(h)
  end

  def timeout
      h = load_hash_from_xml
      h['NMAgent']['timeout']
  end

  def timeout=(t)
      h = load_hash_from_xml
      h['NMAgent']['timeout'] = t
      save_xml_from_hash(h)
  end

  def port
      h = load_hash_from_xml
      h['NMAgent']['port']
  end

  def port=(p)
      h = load_hash_from_xml
      h['NMAgent']['port'] = p
      save_xml_from_hash(h)
  end

  def protocol
      h = load_hash_from_xml
      if h['NMAgent']['protocol'] == 1
          "TCP"
      else
          "UDP"
      end
  end

  def protocol=(p)
      h = load_hash_from_xml
      h['NMAgent']['protocol'] = if p == "TCP"
                                     1
                                 else
                                     0
                                 end
      save_xml_from_hash(h)
  end

  def train_count
      h = load_hash_from_xml
      h['NMAgent']['train-count']
  end

  def train_count=(tc)
      h = load_hash_from_xml
      h['NMAgent']['train-count'] = tc
      save_xml_from_hash(h)
  end

  def probe_size
      h = load_hash_from_xml
      h['NMAgent']['probe-size']
  end

  def probe_size=(ps)
      h = load_hash_from_xml
      h['NMAgent']['probe-size'] = ps
      save_xml_from_hash(h)
  end

  def train_len
      h = load_hash_from_xml
      h['NMAgent']['train-len']
  end

  def train_len=(t)
      h = load_hash_from_xml
      h['NMAgent']['train-len'] = t
      save_xml_from_hash(h)
  end

  def interval
      h = load_hash_from_xml
      h['NMAgent']['gap-value']
  end

  def interval=(gv)
      h = load_hash_from_xml
      h['NMAgent']['gap-value'] = gv
      save_xml_from_hash(h)
  end

  def mode
      h = load_hash_from_xml
      case h['NMAgent']['time-mode']
      when "0"
          "normal"
      when "1"
          "time"
      when "2"
          "mixed"
      else
          "ERROR"
      end
  end

  def mode=(tm)
      h = load_hash_from_xml
      h['NMAgent']['time-mode'] = if tm == "normal"
                                      0
                                  elsif tm == "time"
                                      1
                                  elsif tm == "mixed"
                                      2
                                  end
      save_xml_from_hash(h)
  end

  def time
      h = load_hash_from_xml
      h['NMAgent']['max-time']
  end

  def time=(mt)
      h = load_hash_from_xml
      h['NMAgent']['max-time'] = mt
      save_xml_from_hash(h)
  end

  def num_conexoes
      h = load_hash_from_xml
      h['NMAgent']['num-conexoes']
  end

  def num_conexoes=(nc)
      h = load_hash_from_xml
      h['NMAgent']['num-conexoes'] = nc
      save_xml_from_hash(h)
  end

  def ignore_gap
      h = load_hash_from_xml
      h['NMAgent']['ignore-gap']
  end

  def ignore_gap(ig)
      h = load_hash_from_xml
      h['NMAgent']['ignore-gap'] = ig
      save_xml_from_hash(h)
  end

  def plugins
      h = load_hash_from_xml
      h['NMAgent']['plugins']
  end

  def plugins=(ps)
      h = load_hash_from_xml
      h['NMAgent']['plugins'] = ps
      save_xml_from_hash(h)
  end

  def type_test
      nil
  end

  def type_test=(t)
  end

  def source_probe
      h = load_hash_from_xml
      h['NMAgent']['agt-index']
  end

  def source_probe=(t)
      # t eh a id de uma probe
      h = load_hash_from_xml
      p = Probe.find(t)
      h['NMAgent']['agt-index'] = t
      h['NMAgent']['literal-addr'] = p.ipaddress
      h['NMAgent']['android'] = if p.type == "android"
                                    1
                                else
                                    0
                                end
      h['NMAgent']['location'] ||= {}
      h['NMAgent']['location']['name'] = p.name
      h['NMAgent']['location']['city'] = p.city
      h['NMAgent']['location']['state'] = p.state
      save_xml_from_hash(h)
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
      if self.config_method == "raw_xml" || self.config_method.nil?
          if self.config_parameters == "" || self.config_parameters.nil?
              self.config_parameters = "<NMAgent></NMAgent>"
          end
          XmlSimple.xml_in(self.config_parameters, { 'KeepRoot' => true, 'ForceArray' => false, 'NoAttr' => true })
      else
          {}
      end
  end

  def save_xml_from_hash(h)
      if self.config_method == "raw_xml" || self.config_method.nil?
          self.config_parameters = XmlSimple.xml_out(h, { 'KeepRoot' => true, 'NoAttr' => true })
      end
  end
end
