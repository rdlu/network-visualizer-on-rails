class ThresholdValue < ActiveRecord::Base

  belongs_to  :metrics
  belongs_to  :threshlodprofile, :foreign_key => "thresholdprofile_id"


  attr_accessible :min, :max


end
