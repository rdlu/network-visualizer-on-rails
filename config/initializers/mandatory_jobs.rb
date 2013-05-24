if ((defined?(::Passenger) && defined?(::Passenger::AbstractServer)) || defined?(::IN_PHUSION_PASSENGER)) || (defined?(::WEBrick) && defined?(::WEBrick::VERSION))
  Delayed::Job.destroy_all(:queue => 'calculate')
  Delayed::Job.destroy_all(:queue => 'updatetop100')
  Delayed::Job.destroy_all(:queue => 'checkstatus')

  #calculo de medianas todos os dias
  Delayed::Job.enqueue CalculateMediansJob.new(Time.now.end_of_day,true), :queue => 'calculate', :run_at => DateTime.current.end_of_day+1.hour
  Delayed::Job.enqueue CalculateMonthlyCompliance.new(Time.now.end_of_day,true), :queue => 'calculate', :run_at => DateTime.current.end_of_day+1.hour
  Delayed::Job.enqueue UpdateTopSitesJob.new, :queue => 'updatetop100', :run_at => DateTime.current.end_of_day
  Delayed::Job.enqueue VerifyStatus.new, :queue => 'checkstatus', :run_at => DateTime.current + 5.minutes
end
