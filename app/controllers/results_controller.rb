class ResultsController < ApplicationController
  def index
  end

  def create
    filtered_params = params.except('controller', 'action', 'destination_id')
    @results = Results.new(filtered_params)

    source_ip = request.remote_ip
    #source_ip = '143.54.85.34'
    @source = Probe.find_by_ipaddress(source_ip)
    @destination = Probe.find(params[:destination_id])
    @metric = Metric.find_by_plugin(params[:metric_name])

    @schedule = Schedule.where(:destination_id => @destination.id).where(:source_id => @source.id).all.last

    #atualiza o timestamp
    @source.status = 1
    @source.updated_at=DateTime.current
    @source.save!
    @destination.status = 1
    @destination.updated_at=DateTime.current
    @destination.save!
    @schedule.status = 'active'
    @schedule.updated_at=DateTime.current
    @schedule.save!

    @results.schedule = @schedule
    @results.metric = @metric

    if @results.save
      @status = 'OK'
    else
      @status = 'Fail'
    end

    # write to cache
    Rails.cache.write "results_#{@source.id}_#{@destination.id}", "#{@results.to_json}"
    Rails.cache.write "schedule_#{@source.id}_#{@destination.id}", "#{@schedule.to_json}"
    Rails.cache.write "probe_#{@destination.id}", "#{@destination.to_json}"

    render :file => 'results/create', :formats => [:xml], :layout => false
  end
end
