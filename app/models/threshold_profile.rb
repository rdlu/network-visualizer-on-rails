class ThresholdProfile < ActiveRecord::Base

  has_many  :processes  #why???
  has_many  :thresholdvalues
  has_many  :metrics, :throw => :thresholdvalues, :foreign_key => "metric_id"

  attr_accessible :name, :desc


  #sprig()  ????
end
