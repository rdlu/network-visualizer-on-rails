require 'xmlsimple'

class Profile < ActiveRecord::Base
  attr_accessible :config_method, :config_parameters, :name, :connection_profile_id, :metric_ids, :nameservers, :sites
  attr_accessible :type_test, :source_probe, :timeout, :probe_size, :train_count, :metrics, :train_len, :time, :interval, :plugins, :protocol, :mode
  attr_accessible :http_numcon, :http_download_testtime, :http_download_file, :http_upload_path, :http_upload_file

  #relationships
  belongs_to :connection_profile
  has_and_belongs_to_many :metrics
  has_many :schedules, :through => :evaluations

  accepts_nested_attributes_for :metrics

  def plugins
      h = load_hash_from_xml
      Metric.where(plugin: h['ativas']['plugins']).all
  end

  def plugins=(ms)
      h = load_hash_from_xml
      h['ativas']['plugins'] = ms
      save_xml_from_hash(h)
  end

  def manager_ip
      h = load_hash_from_xml
      h['ativas']['manager-ip']
  end

  def manager_ip=(m)
      h = load_hash_from_xml
      h['ativas']['manager-ip'] = m
      save_xml_from_hash(h)
  end

  def timeout
      h = load_hash_from_xml
      h['ativas']['timeout']
  end

  def timeout=(t)
      h = load_hash_from_xml
      h['ativas']['timeout'] = t
      save_xml_from_hash(h)
  end

  def port
      h = load_hash_from_xml
      h['ativas']['port']
  end

  def port=(p)
      h = load_hash_from_xml
      h['ativas']['port'] = p
      save_xml_from_hash(h)
  end

  def protocol
      h = load_hash_from_xml
      if h['ativas']['protocol'] == "1"
          "tcp"
      else
          "udp"
      end
  end

  def protocol=(p)
      h = load_hash_from_xml
      h['ativas']['protocol'] = if p == "tcp"
                                     "1"
                                 else
                                     "0"
                                 end
      save_xml_from_hash(h)
  end

  def train_count
      h = load_hash_from_xml
      h['ativas']['train-count']
  end

  def train_count=(tc)
      h = load_hash_from_xml
      h['ativas']['train-count'] = tc
      save_xml_from_hash(h)
  end

  def probe_size
      h = load_hash_from_xml
      h['ativas']['probe-size']
  end

  def probe_size=(ps)
      h = load_hash_from_xml
      h['ativas']['probe-size'] = ps
      save_xml_from_hash(h)
  end

  def train_len
      h = load_hash_from_xml
      h['ativas']['train-len']
  end

  def train_len=(t)
      h = load_hash_from_xml
      h['ativas']['train-len'] = t
      save_xml_from_hash(h)
  end

  def interval
      h = load_hash_from_xml
      h['ativas']['gap-value']
  end

  def interval=(gv)
      h = load_hash_from_xml
      h['ativas']['gap-value'] = gv
      save_xml_from_hash(h)
  end

  def mode
      h = load_hash_from_xml
      case h['ativas']['time-mode']
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
      h['ativas']['time-mode'] = if tm == "normal"
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
      h['ativas']['max-time']
  end

  def time=(mt)
      h = load_hash_from_xml
      h['ativas']['max-time'] = mt
      save_xml_from_hash(h)
  end

  def num_conexoes
      h = load_hash_from_xml
      h['ativas']['num-conexoes']
  end

  def num_conexoes=(nc)
      h = load_hash_from_xml
      h['ativas']['num-conexoes'] = nc
      save_xml_from_hash(h)
  end

  def ignore_gap
      h = load_hash_from_xml
      h['ativas']['ignore-gap']
  end

  def ignore_gap=(ig)
      h = load_hash_from_xml
      h['ativas']['ignore-gap'] = ig
      save_xml_from_hash(h)
  end

  def type_test
      nil
  end

  def type_test=(t)
  end

  def source_probe
      h = load_hash_from_xml
      h['ativas']['agt-index']
  end

  def source_probe=(t)
      # t eh a id de uma probe
      h = load_hash_from_xml
      p = Probe.find(t)
      h['ativas']['agt-index'] = t
      h['ativas']['literal-addr'] = p.ipaddress
      h['ativas']['android'] = if p.type == "android"
                                    1
                                else
                                    0
                                end
      h['ativas']['location'] ||= {}
      h['ativas']['location']['name'] = p.name
      h['ativas']['location']['city'] = p.city
      h['ativas']['location']['state'] = p.state
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

  def http_numcon
      self.config_parameters ||= setup_http_params
      a = ActiveSupport::JSON.decode(self.config_parameters)["download"]["numCon"]
      if a
          a
      else
          []
      end
  end

  def http_numcon=(n)
      self.config_parameters ||= setup_http_params
      cfg_params = ActiveSupport::JSON.decode(self.config_parameters)
      cfg_params["download"]["numCon"] = n
      self.config_parameters = cfg_params.to_json
  end

  def http_download_testtime
      self.config_parameters ||= setup_http_params
      a = ActiveSupport::JSON.decode(self.config_parameters)["download"]["testTime"]
      if a
          a
      else
          0
      end
  end

  def http_download_testtime=(t)
      self.config_parameters ||= setup_http_params
      cfg_params = ActiveSupport::JSON.decode(self.config_parameters)
      cfg_params["download"]["testTime"] = t
      self.config_parameters = cfg_params.to_json
  end

  def http_download_file
      self.config_parameters ||= setup_http_params
      a = ActiveSupport::JSON.decode(self.config_parameters)["download"]["path"]
      if a
          a
      else
          [{}]
      end
  end

  def http_download_file=(p)
      self.config_parameters ||= setup_http_params
      cfg_params = ActiveSupport::JSON.decode(self.config_parameters)
      cfg_params["download"]["path"] = p
      self.config_parameters = cfg_params.to_json
  end

  def http_upload_path
      self.config_parameters ||= setup_http_params
      a = ActiveSupport::JSON.decode(self.config_parameters)["upload"]["path"]
      if a
          a
      else
          ""
      end
  end

  def http_upload_path=(p)
      self.config_parameters ||= setup_http_params
      cfg_params = ActiveSupport::JSON.decode(self.config_parameters)
      cfg_params["upload"]["path"] = p
      self.config_parameters = cfg_params.to_json
  end

  def http_upload_file
      self.config_parameters ||= setup_http_params
      a = ActiveSupport::JSON.decode(self.config_parameters)["upload"]["file"]
      if a
          a
      else
          ""
      end
  end

  def http_upload_file=(f)
      self.config_parameters ||= setup_http_params
      cfg_params = ActiveSupport::JSON.decode(self.config_parameters)
      cfg_params["upload"]["file"] = f
      self.config_parameters = cfg_params.to_json
  end

  private

  def load_hash_from_xml
      if self.config_method == "raw_xml" || self.config_method.nil?
          if self.config_parameters == "" || self.config_parameters.nil?
              self.config_parameters = "<ativas></ativas>"
          end
          XmlSimple.xml_in(self.config_parameters, { 'KeepRoot' => true, 'ForceArray' => false, 'NoAttr' => true, 'AnonymousTag' => 'ativas' })
      else
          {}
      end
  end

  def save_xml_from_hash(h)
      if self.config_method == "raw_xml" || self.config_method.nil?
          self.config_parameters = XmlSimple.xml_out(h, { 'KeepRoot' => true, 'NoAttr' => true, 'AnonymousTag' => 'ativas' })
      end
  end

  def setup_http_params
      {download: {numCon: 0, testTime: 0, path: ""}, upload: {path: "", file: ""}}.to_json
  end
end
