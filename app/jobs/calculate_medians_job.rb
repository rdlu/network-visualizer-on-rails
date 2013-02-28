# coding: utf-8
class CalculateMediansJobException < Exception

end

class CalculateMediansJob
  def enqueue(job)

  end

  def perform
    Schedule.all do |schedule|
      schedule.metrics do |metric|
        metric.thresholds do |threshold|
          if threshold.goal_method == 'median'
            Median.calculate schedule, threshold, Date.yesterday.at_beginning_of_day
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