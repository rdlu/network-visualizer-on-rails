class KpiController < ApplicationController
  def index
  end

  def create
    filtered_params = params.except('controller', 'action', 'destination_id')
    @kpi = Kpi.new(filtered_params)

    #relacionamentos
    source_ip = request.remote_ip
    #source_ip = '143.54.85.34'
    @source = Probe.find_by_ipaddress(source_ip)
    @destination = Probe.find(params[:destination_id])
    @schedule = Schedule.
        where(:destination_id => @destination.id).
        where(:source_id => @source.id).
        all.last

    @kpi.schedule = @schedule
    @kpi.destination = @destination
    @kpi.source = @source

    @kpi.destination_name = @destination.name
    @kpi.source_name = @source.name

    if @kpi.save
      @status = 'OK'
    else
      @status = 'Fail'
    end

    # Write to cache
    Rails.cache.write "kpi_#{@destination.id}", "#{@kpi.to_json}"
    Rails.cache.write "schedule_#{@source.id}_#{@destination.id}", "#{@schedule.to_json}"
    Rails.cache.write "probe_#{@destination.id}", "#{@destination.to_json}"

    render :file => 'kpis/create', :formats => [:xml], :layout => false
  end

  def show
    kpi = Kpi.find_by_uuid(params[:uuid])

    respond_to do |format|
      format.json { render :json => kpi, :status => 200 }
    end
  end
end
