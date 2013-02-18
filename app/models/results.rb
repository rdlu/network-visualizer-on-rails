class Results < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :metric
  attr_accessible :dsavg, :dsmax, :dsmin, :schedule_uuid, :sdavg, :sdmax, :sdmin, :timestamp, :uuid, :metric_name

  def timestamp= value
    if value.is_a? Date
      self[:timestamp] = value.to_datetime
    else
      #converte do formato UNIX TIMESTAMP
      self[:timestamp] = DateTime.strptime(value, '%s')
    end
  end
end
