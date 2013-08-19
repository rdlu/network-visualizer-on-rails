# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
set :output, {:error => '/usr/share/mom-rails/log/cron_error.log', :standard => '/usr/share/mom-rails/log/cron_status.log'}
set :job_template, "bash -i -c ':job'"
env :PATH, ENV['PATH']

job_type :restart, "cd :path && touch tmp/restart.txt && echo \"MoM reiniciado `date`\" >> log/cron_status.log"

every 5.minutes do
  runner 'VerifyStatus.perform'
end

every 1.day, :at => '0:15 am' do
  runner 'UpdateTopSites.perform'
end

every 1.day, :at => '1:00 am' do
  runner 'CalculateMedians.perform'
end

every 1.day, :at => '2:00 am' do
  runner 'CalculateCompliances.perform'
end

every 3.hour do
  restart 's'
end