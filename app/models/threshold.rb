# coding: utf-8
class Threshold < ActiveRecord::Base
  attr_accessible :compliance_level, :compliance_period, :compliance_method, :goal_level, :goal_method, :goal_period, :name, :metric_id, :connection_profile_id

  belongs_to :connection_profile
  belongs_to :metric

  def goal_methods
    [%w(Mediana median),
    ["Valor Bruto","raw"]]
  end

  def goal_periods
    [%w(Diária-PMT daily-rush),
    %w(Diária daily),
    %w(Individual each)]
  end

  def compliance_methods
    [["Quociente simples","quotient"],
    ["Média",'mean']]
  end

  def compliance_periods
    [%w(Mensal monthly)]
  end
end
