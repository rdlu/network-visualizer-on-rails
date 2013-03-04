# coding: utf-8
class Threshold < ActiveRecord::Base
  attr_accessible :compliance_level, :compliance_period, :compliance_method, :goal_level, :goal_method, :goal_period, :name,:description, :metric_id, :connection_profile_id, :base_year

  belongs_to :connection_profile
  belongs_to :metric

  has_many :medians, :conditions => {:goal_method => 'median'}

  def goal_methods
    [%w(Mediana median),
    ['Valor Bruto', 'raw'],
    ['Disponibilidade Composta', 'availability']]
  end

  def goal_periods
    [%w(Diária-PMT daily-rush),
    %w(Diária daily),
    %w(Individual-PMT each-rush),
    %w(Individual each)]
  end

  def compliance_methods
    [['Quociente simples', 'quotient'],
    ['Quociente da Média','mean']]
  end

  def compliance_periods
    [%w(Mensal monthly)]
  end

  def base_years
    [2013,2014,2015]
  end

  def find_goal_name method
    method_name = method.to_s.pluralize
    lines = self.method(method_name.to_sym).call
    value = self.method(method.to_sym).call

    lines.each do |line|
      return line.at(0) if line.at(1) == value.to_s
      return line.at(1) if line.at(0) == value.to_s
    end
    'NameNotFound'
  end
end
