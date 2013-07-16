# coding: utf-8
class CalculateMediansJobException < Exception

end

class CalculateMediansJob
  def initialize(reference_date = Time.now.end_of_day, reeschedule = false, force_disabled = false)
    @reference_date= reference_date.to_time
    @reeschedule = reeschedule
    @force_disabled = force_disabled
  end

  def enqueue(job)
    Yell.new(:gelf, :facility => 'netmetric-jobs').info 'Calculo de medianas entrou na fila'
  end

  def perform
    Yell.new(:gelf, :facility => 'netmetric-jobs').info "Perform: Calculo de medianas #{@reference_date} #{@reeschedule} #{@force_disabled}"
    Schedule.all.each do |schedule|
      if schedule.destination.status != 0 || @force_disabled
        schedule.metrics.each do |metric|
          metric.thresholds.each do |threshold|
            Median.calculate schedule, threshold, @reference_date
          end
        end
      end
    end
  end

  def before(job)
    Yell.new(:gelf, :facility => 'netmetric-jobs').info 'Calculo de medianas iniciando...'
  end

  def after(job)
    Yell.new(:gelf, :facility => 'netmetric-jobs').info 'Calculo de medianas encerrado.'
  end

  def success(job)
    Yell.new(:gelf, :facility => 'netmetric-jobs').info 'Calculo de medianas encerrado com sucesso.'
    #programa a próxima chamada
    if @reeschedule
      Delayed::Job.enqueue CalculateMediansJob.new(Time.now.end_of_day,true), :queue => 'calculate', :run_at => DateTime.current.end_of_day+1.hour
    end
  end

  def error(job, exception)
    Yell.new(:gelf, :facility => 'netmetric-jobs').error 'Ooops no calculo de mediana.'
    Airbrake.notify(exception)
  end

  def failure
    #programa a próxima chamada
    if @reeschedule
      Delayed::Job.enqueue CalculateMediansJob.new(Time.now.end_of_day,true), :queue => 'calculate', :run_at => DateTime.current.end_of_day+1.hour
    end
  end
end