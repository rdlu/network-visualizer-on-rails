# coding: utf-8
class ReportsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @report_types = [
        ['Gráfico de Indicadores Anatel/EAQ - Consolidação Diária','eaq_graph'],
        ['Gráfico de Indicadores Anatel/EAQ - Consolidação Mensal','eaq_compliance_graph'],
        ['Gráfico de Dados Brutos','graph'],
        ['Tabela de Indicadores Anatel/EAQ','eaq_table']
    ]
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
            :x => raw_result.timestamp,
            :dsavg => raw_result.dsavg,
            :sdavg => raw_result.sdavg,
            :dsmin => raw_result.dsmin,
            :dsmax => raw_result.dsmax,
            :sdmin => raw_result.sdmin,
            :sdmax => raw_result.sdmax,
            :extra => { :uuid => raw_result.uuid }
        }
      end
    else
      raw_results.each do |raw_result|
        results << {
            :x => raw_result.timestamp,
            :dsavg => raw_result.dsavg,
            :dsmin => raw_result.dsmin,
            :dsmax => raw_result.dsmax,
            :extra => { :uuid => raw_result.uuid }
        }
      end
    end

    data = {
        :source => source,
        :destination => destination,
        :metric => metric,
        :schedule => schedule,
        :range => { :start => from, :end => to },
        :results => results
    }

    respond_to do |format|
      format.json { render :json => data, :status => 200 }
    end
  end

  def eaq_graph
    source = Probe.find(params[:source][:id])
    destination = Probe.find(params[:destination][:id])
    schedule = Schedule.where(:destination_id => destination.id).where(:source_id => source.id).all.last
    threshold = Threshold.find(params[:metric][:id])
    metric = threshold.metric

    from = DateTime.parse(params[:date][:start]+' '+params[:time][:start]+' '+DateTime.current.zone).beginning_of_day.in_time_zone
    to = DateTime.parse(params[:date][:end]+' '+params[:time][:end]+' '+DateTime.current.zone).end_of_day.in_time_zone

    raw_medians = Median.
        where(:schedule_id => schedule.id).
        where(:threshold_id => threshold.id).
        where('start_timestamp >= ?', from).
        where('end_timestamp <= ?', to).
        order('start_timestamp ASC').all


    reference_metric = metric.plugin.split('_').at(0)
    case reference_metric
      when 'throughput'
        graph_threshold = {
            :download => (destination.plan[reference_metric+'_down']*1024) * threshold.goal_level,
            :upload =>  (destination.plan[reference_metric+'_up']*1024) * threshold.goal_level,
        }
      when 'rtt'
        graph_threshold = {
            :rtt => threshold.goal_level * 0.001
        }
      when 'jitter'
        graph_threshold = {
            :jitter => threshold.goal_level * 0.001
        }
      else
        graph_threshold = {
            :download => threshold.goal_level,
            :upload =>  threshold.goal_level,
        }
    end

    results = []
    if metric.plugin != 'rtt'
      raw_medians.each do |raw_median|
        results << {
            :x => raw_median.start_timestamp.midnight,
            :dsavg => raw_median.dsavg,
            :sdavg => raw_median.sdavg
        }
      end
    else
      raw_medians.each do |raw_median|
        results << {
            :x => raw_median.start_timestamp.midnight,
            :y => raw_median.dsavg
        }
      end
    end

    data = {
        :source => source,
        :destination => destination,
        :metric => metric,
        :threshold => threshold,
        :schedule => schedule,
        :range => { :start => from, :end => to },
        :results => results,
        :goal_line => graph_threshold
    }

    respond_to do |format|
      format.json { render :json => data, :status => 200 }
    end
  end

  def eaq_compliance_graph
    source = Probe.find(params[:source][:id])
    destination = Probe.find(params[:destination][:id])
    schedule = Schedule.where(:destination_id => destination.id).where(:source_id => source.id).all.last
    threshold = Threshold.find(params[:metric][:id])
    metric = threshold.metric

    from = DateTime.parse(params[:date][:start]+' '+params[:time][:start]+' '+DateTime.current.zone).beginning_of_day.in_time_zone('GMT')
    to = DateTime.parse(params[:date][:end]+' '+params[:time][:end]+' '+DateTime.current.zone).end_of_day.in_time_zone('GMT')

    raw_compliances = Compliance.
        where(:schedule_id => schedule.id).
        where(:threshold_id => threshold.id).
        where('start_timestamp >= ?', from).
        where('end_timestamp <= ?', to.end_of_month).
        order('start_timestamp ASC').all

    results = []
    reference_metric = metric.plugin.split('_').at(0)
    if reference_metric == 'throughput'
      raw_compliances.each do |raw_compliance|
        results << {
            :x => raw_compliance.end_timestamp.beginning_of_month,
            :download => raw_compliance.download,
            :upload => raw_compliance.upload
        }
      end
    else
      raw_compliances.each do |raw_compliance|
        results << {
            :x => raw_compliance.end_timestamp.beginning_of_month,
            :y => raw_compliance.download
        }
      end
    end

    data = {
        :source => source,
        :destination => destination,
        :metric => metric,
        :threshold => threshold,
        :schedule => schedule,
        :range => { :start => from, :end => to },
        :results => results
    }

    respond_to do |format|
      format.json { render :json => data, :status => 200 }
    end
  end

  def csv
    source = Probe.find(params[:source][:id])
    destination = Probe.find(params[:destination][:id])
    metric = Metric.find(params[:metric][:id])
    schedule = Schedule.where(:destination_id => destination).where(:source_id => source).all.last

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

  def eaq_table
    @source = Probe.find(params[:source][:id])
    @destination = Probe.find(params[:destination][:id])
    @schedule = Schedule.where(:destination_id => @destination.id).where(:source_id => @source.id).all.last

    @from = DateTime.parse(params[:date][:start])
    @to = DateTime.parse(params[:date][:end])

    @months = @from.all_months_until @to
    @thresholds = @destination.thresholds @source

    respond_to do |format|
      format.html {render :layout=> false}
    end

  end

  def detail_eaq_table
    @source = Probe.find(params[:source])
    @destination = Probe.find(params[:destination])
    @thresholds = @destination.thresholds @source
    @month = params[:month]
    @schedule = Schedule.find(params[:schedule])

    respond_to do |format|
      format.html {render :layout=> false}
    end
  end

end
