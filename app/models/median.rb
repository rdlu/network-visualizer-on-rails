class Median < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :threshold
  attr_accessible :end_timestamp, :expected_points, :schedule_uuid, :start_timestamp, :total_points, :dsavg, :sdavg

  def calculate (schedule, threshold, start_timestamp, end_timestamp)
    #TODO: calcular metricas anatel que sao do tipo mediana
  end
end
