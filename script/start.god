# run with: god -c /path/to/file.god -D
RAILS_ROOT = "/usr/share/mom-rails"

[
    {id:1,queue:'calculate'},
    {id:2,queue:'calculate'},
    {id:3,queue:'checkstatus'},
    {id:4,queue:'updatetop100'}
].each do |job|
  God.watch do |w|
    w.group = "mom"
    w.name = "delayed_job #{job[:queue]} #{job[:id]}"
    w.interval = 30.seconds # default
    w.dir = RAILS_ROOT
    w.start = File.join(RAILS_ROOT, "script/delayed_job --queue=#{job[:queue]} -i=#{job[:id]} start")
    w.stop = File.join(RAILS_ROOT, "script/delayed_job --queue=#{job[:queue]} -i=#{job[:id]} stop")
    w.restart = File.join(RAILS_ROOT, "script/delayed_job --queue=#{job[:queue]} -i=#{job[:id]} restart")
    w.start_grace = 15.seconds
    w.restart_grace = 15.seconds
    w.pid_file = File.join(RAILS_ROOT, "tmp/pids/delayed_job.=#{job[:id]}.pid")
    w.log = File.join(RAILS_ROOT, 'log/god.log')

    w.behavior(:clean_pid_file)

    w.start_if do |on|
      on.condition(:process_running) do |c|
        c.interval = 5.seconds
        c.running = false
      end
    end
  end
end