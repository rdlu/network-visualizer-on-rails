# coding: utf-8
class Plan < ActiveRecord::Base
  attr_accessible :description, :name, :throughput_down, :throughput_up, :connection_profile_id

  validates :name, :presence => true, :length => {:maximum => 255, :minimum => 3}
  validates_uniqueness_of :name
  validates :throughput_down, :presence => true, :numericality => { :only_integer => true }
  validates :throughput_up, :presence => true, :numericality => { :only_integer => true }

  #relationships
  has_many :probes
  belongs_to :connection_profile

  #escopos de pesquisa
  scope :by_connection_profile, proc { |connection_profile| where(:connection_profile => connection_profile)}

  def name_with_throughput
    self.name+" ("+self.throughput_down.to_s+"k"+8659.chr+"/"+self.throughput_up.to_s+"k"+8657.chr+")".html_safe
  end

  def throughput_down_with_unit(auto_choose_unit = false)
    throughput = self.throughput_down.to_unit('kb/s')
    if auto_choose_unit
      if throughput > '1 Mb/s'.to_unit
        return throughput.convert_to('Mb/s')
      end
    end
    throughput
  end

  def throughput_up_with_unit(auto_choose_unit = false)
    throughput = self.throughput_up.to_unit('kb/s')
    if auto_choose_unit
      if throughput > '1 Mb/s'.to_unit
        return throughput.convert_to('Mb/s')
      end
    end
    throughput
  end

end