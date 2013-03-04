# coding: utf-8
class CalculateMediansJobException < Exception

end

class CalculateMediansJob

  def enqueue(job)

  end

  def perform(reference_date = Date.yesterday.at_beginning_of_day, reeschedule = true, force_disabled = false)
    #programa a próxima chamada
    if reeschedule
      Delayed::Job.enqueue CalculateMediansJob.new, :queue => 'calculate', :run_at => Date.current.end_of_day+1.hour
    end

    Schedule.all.each do |schedule|
      if schedule.destination.status != 0 || force_disabled
        schedule.metrics.each do |metric|
          metric.thresholds.each do |threshold|
            if threshold.goal_method == 'median'
              Median.calculate schedule, threshold, reference_date
            end
          end
        end
      end
    end
  end

  def before(job)
    Yell.new(:gelf, :facility => 'netmetric').info 'Calculo de medianas iniciando...'
  end

  def after(job)
    Yell.new(:gelf, :facility => 'netmetric').info 'Calculo de medianas encerrado.'
  end

  def success(job)
    Yell.new(:gelf, :facility => 'netmetric').info 'Calculo de medianas encerrado com sucesso.'
  end

  def error(job, exception)
    Yell.new(:gelf, :facility => 'netmetric').error 'Ooops no calculo de mediana.'
    Airbrake.notify(exception)
  end

  def failure

  end
end