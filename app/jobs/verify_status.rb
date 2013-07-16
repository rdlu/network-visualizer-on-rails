# coding: utf-8
require 'open-uri'

class UpdateTopSitesJobException < Exception

end

class VerifyStatus
  def enqueue(job)

  end

  def perform
    Probe.all.each do |probe|
      unless probe.schedules.empty?
        if probe.updated_at < Time.now - (probe.schedules.first.polling*2).minutes
          probe.status = 2
        end

        if probe.updated_at < Time.now - (probe.schedules.first.polling*3).minutes
          probe.status = 3
        end

        probe.record_timestamps=false
        probe.save
        probe.record_timestamps=true
      end
    end

  end

  def before(job)
  end

  def after(job)
  end

  def success(job)
    #Yell.new(:gelf, :facility => 'netmetric').info 'Update do Top100 Sites encerrado com sucesso'
    Delayed::Job.enqueue VerifyStatus.new, :queue => 'checkstatus', :run_at => DateTime.current + 5.minutes
  end

  def error(job, exception)
    Yell.new(:gelf, :facility => 'netmetric').info 'Erro na verificação dos status das sondas'
  end

  def failure
    Yell.new(:gelf, :facility => 'netmetric').info 'Falha na verificação dos status das sondas'
    Airbrake.notify(exception)
    Delayed::Job.destroy_all(:queue => 'checkstatus')
    Delayed::Job.enqueue VerifyStatus.new, :queue => 'checkstatus', :run_at => DateTime.current + 5.minutes
  end
end
