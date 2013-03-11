class Profile < ActiveRecord::Base
  attr_accessible :config_method, :config_parameters, :name, :connection_profile_id, :metric_ids, :nameservers

  #relationships
  belongs_to :connection_profile
  has_and_belongs_to_many :metrics
  has_many :schedules, :through => :evaluations

  accepts_nested_attributes_for :metrics

  def nameservers=(ns)
    self.config_parameters = ns.to_json
  end

  def nameservers
    self.config_parameters if self.config_method == "dns"
  end
end
