class CalculateMedians
  def self.perform
    Yell.new(:gelf, :facility => 'netmetric-jobs').info "Perform: Calculo de medianas"
    Schedule.all.each do |schedule|
      if schedule.destination.status != 0
        schedule.metrics.each do |metric|
          metric.thresholds.each do |threshold|
            Median.calculate schedule, threshold, Time.now.end_of_day - 1.day
          end
        end
      end
    end
  end
end