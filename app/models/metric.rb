# == Schema Information
#
# Table name: metrics
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  plugin      :string(255)
#  description :string(255)
#  reverse     :boolean
#  order       :integer
#  created_at  :timestamp(6)     not null
#  updated_at  :timestamp(6)     not null
#  view_unit   :string(255)
#  db_unit     :string(255)
#  metric_type :string(255)      default("active"), not null
#

class Metric < ActiveRecord::Base
  attr_accessible :description, :name, :order, :plugin, :reverse, :db_unit, :view_unit, :metric_type

  validates :name, :presence => true, :length => {:maximum => 30, :minimum => 3}, :uniqueness => true
  validates :plugin, :presence => true, :length => {:maximum => 20, :minimum => 3}, :uniqueness => true,
            :format => {:with => /[a-z0-9]+/}
  has_and_belongs_to_many :profiles
  has_many :thresholds

  def db_unit
    self[:db_unit].to_s.gsub(/b\/s|B\/s/, 'b/s' => 'bps', 'B/s' => 'Bps')
  end

  def raw_db_unit
    self[:db_unit]
  end

  def db_unit= (value)
    self[:db_unit] = value.gsub(/bps|Bps/, 'bps' => 'b/s', 'Bps' => 'B/s')
  end

  def view_unit
    self[:view_unit].to_s.gsub(/b\/s|B\/s/, 'b/s' => 'bps', 'B/s' => 'Bps')
  end

  def raw_view_unit
    self[:view_unit]
  end

  def view_unit= (value)
    self[:view_unit] = value.gsub(/bps|Bps/, 'bps' => 'b/s', 'Bps' => 'B/s')
  end

  def metric_types
    [
        ['Métricas ativas', 'active'],
        ['DNS', 'dns'],
        ['DNS Errors', 'dns_detail'],
        ['Eficiencia DNS', 'dns_efficiency'],
        ['Carga Web', 'web_load'],
        ['KPI', 'kpi'],
        ['Outra', '']
    ]
  end

  def search_metric_types(search_term)
    self.metric_types.each do |type|
      return type if type[1] == search_term
    end
  end

  def pretty_metric_type
    self.search_metric_types(self.metric_type)[0]
  end

  def pretty_scalar_convertion(result)
    "#{result} #{self.raw_db_unit}".to_unit(self.raw_view_unit).scalar
  end

  def pretty_human_reverse
    if self.reverse == true
      "Sim"
    else
      "Não"
    end
  end

end
