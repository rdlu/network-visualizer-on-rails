class Date
  #permite iterar as datas mes a mes
  def all_months_until(to)
    from = self
    from, to = to, from if from > to
    m = Date.new from.year, from.month
    result = []
    while m <= to
      result << m
      m >>= 1
    end

    result
  end
end

class Time

  # Returns an array of all border times between the object time and +to+ time in +steps+
  # Example: [Time.current,Time.current+step,Time.current+2*step,...,last_time_before_to, to (by default)]
  # Unit must be supported by Rails Time conversion (5.seconds, 10.minutes, 3.hours, etc)
  #@param to [Time]
  #@param steps [Integer]
  #@return Array[Time]
  def all_window_times_until(to,steps)
    from = self
    from, to = to, from if from > to
    m = Time.new from.year, from.month, from.day, from.hour, from.min, from.sec, from.utc_offset
    result = []
    while m <= to
      result << m
      m += steps
    end

    result
  end
end