if ((defined?(::Passenger) && defined?(::Passenger::AbstractServer)) || defined?(::IN_PHUSION_PASSENGER)) || (defined?(::WEBrick) && defined?(::WEBrick::VERSION))
  Delayed::Job.destroy_all(:queue => 'calculate')

  #calculo de medianas todos os dias
  Delayed::Job.enqueue CalculateMediansJob.new, :queue => 'calculate', :run_at => Date.current.end_of_day+1.hour
end