class ReportsController < ApplicationController
  before_filter :authenticate_user!
  def index
  end

  def graph
    source = Probe.find(params[:source][:id])
    destination = Probe.find(params[:destination][:id])
    metric = Metric.find(params[:metric][:id])
    schedule = Schedule.where(:destination_id => destination.id).where(:source_id => source.id).all.last

    from = DateTime.parse(params[:date][:start]+' '+params[:time][:start]+' '+DateTime.current.zone).in_time_zone
    to = DateTime.parse(params[:date][:end]+' '+params[:time][:end]+' '+DateTime.current.zone).in_time_zone

    raw_results = Results.
        where(:schedule_id => schedule.id).
        where(:metric_id => metric.id).
        where(:timestamp => from..to).order('timestamp ASC').all

    results = []

    if metric.plugin != 'rtt'
      raw_results.each do |raw_result|
        results << {
            'x' => raw_result.timestamp,
            'dsavg' => raw_result.dsavg,
            'sdavg' => raw_result.sdavg,
            'extra' => { 'uuid' => raw_result.uuid }
        }
      end
    else
      raw_results.each do |raw_result|
        results << {
            'x' => raw_result.timestamp,
            'y' => raw_result.dsavg,
            'extra' => { 'uuid' => raw_result.uuid }
        }
      end
    end

    data = {
        'source' => source,
        'destination' => destination,
        'metric' => metric,
        'schedule' => schedule,
        'range' => { 'start' => from, 'end' => to },
        'results' => results
    }

    respond_to do |format|
      format.json { render :json => data, :status => 200 }
    end
  end

  def csv
    source = Probe.find(params[:source][:id])
    destination = Probe.find(params[:destination][:id])
    metric = Metric.find(params[:metric][:id])
    schedule = Schedule.where(:destination_id => destination.id).where(:source_id => source.id).all.last

    from = DateTime.parse(params[:date][:start]+' '+params[:time][:start]+' '+DateTime.current.zone).in_time_zone
    to = DateTime.parse(params[:date][:end]+' '+params[:time][:end]+' '+DateTime.current.zone).in_time_zone

    raw_results = Results.
        where(:schedule_id => schedule.id).
        where(:metric_id => metric.id).
        where(:timestamp => from..to).order('timestamp ASC').all

    @end_csv = CSV.generate do |csv|
      csv << [# source
              "source name",
              "source status",
              "source location",
              # destination
              "destination name",
              "destination status",
              "destination location",
              # metric
              "metric name",
              # schedule
              "schedule start",
              "schedule end",
              "schedule polling",
              "schedule status",
              # date
              "start date",
              "end date",
              # result
              "x",
              unless metric.plugin == 'rtt' then "dsavg" end,
              unless metric.plugin == 'rtt' then  "sdavg" end,
              if metric.plugin == 'rtt' then "y" end,
              "extra"
      ]
      raw_results.each do |result|
        csv << [# source
                source.pretty_name,
                source.pretty_status,
                "#{source.city}/#{source.state.upcase}",
                # destination
                destination.pretty_name,
                destination.pretty_status,
                "#{destination.city}/#{destination.state.upcase}",
                # metric
                metric.name,
                # schedule
                schedule.start,
                schedule.end,
                schedule.polling,
                schedule.status,
                # date
                from,
                to,
                # result
                result.x,
                unless metric.plugin == 'rtt' then result.dsavg end,
                unless metric.plugin == 'rtt' then result.sdavg end,
                if metric.plugin == 'rtt' then result.y end,
                result.extra
        ]
      end
    end

    respond_to do |format|
      format.csv { render text: @end_csv }
    end
  end
end
