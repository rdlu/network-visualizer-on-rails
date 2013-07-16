class CalculateCompliances
  def self.perform
    Yell.new(:gelf, :facility => 'netmetric-jobs').info "Perform: Calculo de compliances"
    Schedule.all.each do |schedule|
      if schedule.destination.status != 0
        schedule.metrics.each do |metric|
          metric.thresholds.where(:compliance_period => 'monthly').each do |threshold|
            Compliance.calculate schedule, threshold, Time.now.end_of_day
          end
        end
      end
    end
  end
end