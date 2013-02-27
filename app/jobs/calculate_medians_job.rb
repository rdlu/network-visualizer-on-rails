# coding: utf-8
class CalculateMediansJobException < Exception

end

class CalculateMediansJob
  def enqueue(job)

  end

  def perform

  end

  def before(job)

  end

  def after(job)

  end

  def success(job)

  end

  def error(job, exception)
    Airbrake.notify(exception)
  end

  def failure

  end
end