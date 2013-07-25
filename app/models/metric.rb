class Metric < ActiveRecord::Base
  attr_accessible :description, :name, :order, :plugin, :reverse, :db_unit, :view_unit, :metric_type

  validates :name, :presence => true, :length => {:maximum => 30, :minimum => 3}, :uniqueness => true
  validates :plugin, :presence => true, :length => {:maximum => 20, :minimum => 3}, :uniqueness => true,
            :format => {:with => /[a-z0-9]+/}
  has_and_belongs_to_many :profiles
  has_many :thresholds

  def db_unit
    self[:db_unit].to_s.gsub(/b\/s|B\/s/,'b/s' => 'bps', 'B/s' => 'Bps')
  end

  def raw_db_unit
    self[:db_unit]
  end

  def db_unit= (value)
    self[:db_unit] = value.gsub(/bps|Bps/,'bps' => 'b/s', 'Bps' => 'B/s')
  end

  def view_unit
    self[:view_unit].to_s.gsub(/b\/s|B\/s/,'b/s' => 'bps', 'B/s' => 'Bps')
  end

  def raw_view_unit
    self[:view_unit]
  end

  def view_unit= (value)
    self[:view_unit] = value.gsub(/bps|Bps/,'bps' => 'b/s', 'Bps' => 'B/s')
  end

  def metric_types
    [
        ['Métricas ativas','active'],
        ['DNS','dns'],
        ['DNS Errors','dns_detail'],
        ['Carga Web','web_load'],
        ['KPI','kpi']
    ]
  end
end
