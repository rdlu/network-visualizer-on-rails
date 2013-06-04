# coding: utf-8
class ReportsController < ApplicationController
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

  def eaq2_table
    @from = DateTime.parse(params[:date][:start])
    @to = DateTime.parse(params[:date][:end])
    @months = @from.all_months_until @to
    @type = params[:agent] # android or linux
    @agent_type = params[:agent_type] # fixed or mobile, if linux
    @states = params[:state]
    @cn = params[:cn]
    @goal_filter = params[:goal_filter] #all,above or under


    if @type == "android"
      @agent_type = ["fixed", "mobile"]
    end

    # Garantir que não tenhamos nulos
    @cn.delete("")
    @states.delete("")

    fixed_conn_profile = ConnectionProfile.
        where(:conn_type => "fixed")

    mobile_conn_profile = ConnectionProfile.
        where(:conn_type => "mobile")

    fixed_probes = Probe.
        where(:connection_profile_id => fixed_conn_profile).
        where(:state => @states).
        where(:areacode => @cn).
        where(:type => @type)

    mobile_probes = Probe.
        where(:connection_profile_id => mobile_conn_profile).
        where(:state => @states).
        where(:areacode => @cn).
        where(:type => @type)

    all_probes = Probe.
        where(:state => @states).
        where(:areacode => @cn).
        where(:type => @type)

    fixed_schedules = Schedule.
        where(:destination_id => fixed_probes)

    mobile_schedules = Schedule.
        where(:destination_id => mobile_probes)

    all_schedules = Schedule.
        where(:destination_id => all_probes)

    @report_results = {}
    #
    #  SCM4
    #
    @report_results[:scm4] = {}
    @medians_scm4 = Median.
        where('start_timestamp >= ?', @from).
        where('end_timestamp <= ?', @to).
        where(:schedule_id => fixed_schedules).
        where(:threshold_id => 1).
        order('start_timestamp ASC').all
    #
    # SMP10
    #
    @report_results[:smp10] = {}
    @medians_smp10 = Median.
        where('start_timestamp >= ?', @from).
        where('end_timestamp <= ?', @to).
        where(:schedule_id => mobile_schedules).
        where(:threshold_id => 1).
        order('start_timestamp ASC').all
    #
    # SCM5
    #
    @report_results[:scm5] = {}
    @medians_scm5 = Median.
        where('start_timestamp >= ?', @from).
        where('end_timestamp <= ?', @to).
        where(:schedule_id => fixed_schedules).
        where(:threshold_id => 2).
        order('start_timestamp ASC').all

    #
    # SMP11
    #
    @report_results[:smp11] = {}
    @medians_smp11 = Median.
        where('start_timestamp >= ?', @from).
        where('end_timestamp <= ?', @to).
        where(:schedule_id => mobile_schedules).
        where(:threshold_id => 2).
        order('start_timestamp ASC').all

    #
    # SCM6
    #
    @report_results[:scm6] = {}
    @medians_scm6 = Median.
        where('start_timestamp >= ?', @from).
        where('end_timestamp <= ?', @to).
        where(:schedule_id => all_schedules).
        where(:threshold_id => 3).
        order('start_timestamp ASC').all

    #
    # SCM7
    #
    @report_results[:scm7] = {}
    @medians_scm7 = Median.
        where('start_timestamp >= ?', @from).
        where('end_timestamp <= ?', @to).
        where(:schedule_id => all_schedules).
        where(:threshold_id => 4).
        order('start_timestamp ASC').all

    #
    # SCM8
    #
    @report_results[:scm8] = {}
    @medians_scm8 = Median.
        where('start_timestamp >= ?', @from).
        where('end_timestamp <= ?', @to).
        where(:schedule_id => all_schedules).
        where(:threshold_id => 5).
        order('start_timestamp ASC').all

    #
    # SCM9
    #
    @report_results[:scm9] = {}
    @medians_scm9 = Median.
        where('start_timestamp >= ?', @from).
        where('end_timestamp <= ?', @to).
        where(:schedule_id => all_schedules).
        where(:threshold_id => 6).
        order('start_timestamp ASC').all

    #
    # Calculo de todas as medias de thresholds
    #
    @months.each do |month|
      # SCM4
      count4 = 0
      count_all4 = 0
      @medians_scm4.each do |median|
          if median.start_timestamp >= month.to_time.in_time_zone && median.start_timestamp <= month.to_time.in_time_zone.end_of_month
              if !median.dsavg.nil? || !median.sdavg.nil?
                  up = (median.dsavg.to_f / (1000 * median.schedule.destination.plan.throughput_up.to_f)).round(3)
                  down = (median.sdavg.to_f / (1000 * median.schedule.destination.plan.throughput_down.to_f)).round(3)
                  count_all4 += 1
                  if down >= median.threshold.goal_level.round(3) && up >= median.threshold.goal_level.round(3)
                      count4 += 1
                  end
              end
          end
      end
      @report_results[:scm4][month.to_s] = {}
      count_all4 != 0 ? @report_results[:scm4][month.to_s][:total] = ((count4 / count_all4) * 100).to_f.round(2): @report_results[:scm4][month.to_s][:total] = 0.0
      
      # SPM10
      count10 = 0
      count_all10 = 0
      @medians_smp10.each do |median|
          if median.start_timestamp >= month.to_time.in_time_zone && median.start_timestamp <= month.to_time.in_time_zone.end_of_month
              if !median.dsavg.nil? || !median.sdavg.nil?
                  up = (median.dsavg.to_f / (1000 * median.schedule.destination.plan.throughput_up.to_f)).round(3)
                  down = (median.sdavg.to_f / (1000 * median.schedule.destination.plan.throughput_down.to_f)).round(3)
                  count_all10 += 1
                  if down >= median.threshold.goal_level.round(3) && up >= median.threshold.goal_level.round(3)
                      count10 += 1
                  end
              end
          end
      end
      @report_results[:smp10][month.to_s] = {}
      count_all10 != 0 ? @report_results[:smp10][month.to_s][:total] = ((count10 / count_all10) * 100).to_f.round(2) : @report_results[:smp10][month.to_s][:total] = 0.0

      # SCM5
      down = 0
      up = 0
      count_all5 = 0
      @medians_scm5.each do |median|
          if median.start_timestamp >= month.to_time.in_time_zone && median.start_timestamp <= month.to_time.in_time_zone.end_of_month
              if !median.dsavg.nil? || !median.sdavg.nil?
                  up = up + (median.dsavg.to_f / (1000 * median.schedule.destination.plan.throughput_up.to_f)).round(3)
                  down = down + (median.sdavg.to_f / (1000 * median.schedule.destination.plan.throughput_down.to_f)).round(3)
                  count_all5 += 1
              end
          end
      end
      @report_results[:scm5][month.to_s] = {}
      count_all5 != 0 ? @report_results[:scm5][month.to_s][:total_down] = ((down / count_all5) * 100).to_f.round(2) : @report_results[:scm5][month.to_s][:total_down] = 0.0
      count_all5 != 0 ? @report_results[:scm5][month.to_s][:total_up] = ((up / count_all5) * 100).to_f.round(2) : @report_results[:scm5][month.to_s][:total_up] = 0.0

      # SMP11
      down = 0
      up = 0
      count_all11 = 0
      @medians_smp11.each do |median|
          if median.start_timestamp >= month.to_time.in_time_zone && median.start_timestamp <= month.to_time.in_time_zone.end_of_month
              if !median.dsavg.nil? || !median.sdavg.nil?
                  up = up + (median.dsavg.to_f / (1000 * median.schedule.destination.plan.throughput_up.to_f)).round(3)
                  down =  down + (median.sdavg.to_f / (1000 * median.schedule.destination.plan.throughput_down.to_f)).round(3)
                  count_all11 += 1
              end
          end
      end
      @report_results[:smp11][month.to_s] = {}
      count_all11 != 0 ? @report_results[:smp11][month.to_s][:total_down] = ((down / count_all11) * 100).to_f.round(2) : @report_results[:smp11][month.to_s][:total_down] = 0.0
      count_all11 != 0 ? @report_results[:smp11][month.to_s][:total_up] = ((up / count_all11) * 100).to_f.round(2) : @report_results[:smp11][month.to_s][:total_up] = 0.0

      # SCM6
      count6 = 0
      count_all6 = 0
      @medians_scm6.each do |median|
          if median.start_timestamp >= month.to_time.in_time_zone && median.start_timestamp <= month.to_time.in_time_zone.end_of_month
              if !median.dsavg.nil?
                  up = median.dsavg.to_f * 1000
                  count_all6 += 1
                  if up <= median.threshold.goal_level.round(3)
                      count6 += 1
                  end
              end
          end
      end
      @report_results[:scm6][month.to_s] = {}
      count_all6 != 0 ? @report_results[:scm6][month.to_s][:total] = ((count6 / count_all6) * 100).to_f.round(2) : @report_results[:scm6][month.to_s][:total] = 0.0

      # SCM7
      count7 = 0
      count_all7 = 0
      @medians_scm7.each do |median|
          if median.start_timestamp >= month.to_time.in_time_zone && median.start_timestamp <= month.to_time.in_time_zone.end_of_month
              if !median.dsavg.nil? || !median.sdavg.nil?
                  down = median.sdavg.to_f * 1000
                  up =  median.dsavg.to_f * 1000
                  count_all7 += 1
                  if down <= median.threshold.goal_level.round(3) && up <= median.threshold.goal_level.round(3)
                      count7 += 1
                  end
              end
          end
      end
      @report_results[:scm7][month.to_s] = {}
      count_all7 != 0 ? @report_results[:scm7][month.to_s][:total] = ((count7 / count_all7) * 100).to_f.round(2) : @report_results[:scm7][month.to_s][:total] = 0.0

      # SCM8
      count8 = 0
      count_all8 = 0
      @medians_scm8.each do |median|
          if median.start_timestamp >= month.to_time.in_time_zone && median.start_timestamp <= month.to_time.in_time_zone.end_of_month
              if  !median.sdavg.nil?
                  down = median.sdavg.to_f
                  count_all8 += 1
                  if down <= median.threshold.goal_level.round(3)
                      count8 += 1
                  end
              end
          end
      end
      @report_results[:scm8][month.to_s] = {}
      count_all8 != 0 ? @report_results[:scm8][month.to_s][:total] = ((count8 / count_all8) * 100).to_f.round(2) : @report_results[:scm8][month.to_s][:total] = 0.0

      # SCM9
      points = 0
      total_points = 0
      @medians_scm9.each do |median|
        if median.start_timestamp >= month.to_time.in_time_zone && median.start_timestamp <= month.to_time.in_time_zone.end_of_month
            points = points + median.expected_points
            total_points = total_points + median.total_points
        end
      end
      @report_results[:scm9][month.to_s] = {}
      points != 0 ? @report_results[:scm9][month.to_s][:total] = ((total_points / points) * 100).to_f.round(2) : @report_results[:scm9][month.to_s][:total] = 0.0

    end

    respond_to do |format|
      format.html  {render :layout=> false}
    end

  end

  def detail_eaq2_table
    @thresholds = Threshold.all
    @month = params[:month]
    @type = params[:agent] # android or linux
    @agent_type = params[:agent_type] # fixed or mobile, if linux
    @states = params[:state]
    @cn = params[:cn]

    if @type == "android"
      @agent_type = ["fixed", "mobile"]
    end

    # Garantir que não tenhamos nulos
    @cn.delete("")
    @states.delete("")

    fixed_conn_profile = ConnectionProfile.
        where(:conn_type => "fixed")

    mobile_conn_profile = ConnectionProfile.
        where(:conn_type => "mobile")

    fixed_probes = Probe.
        where(:connection_profile_id => fixed_conn_profile).
        where(:state => @states).
        where(:areacode => @cn).
        where(:type => @type)

    mobile_probes = Probe.
        where(:connection_profile_id => mobile_conn_profile).
        where(:state => @states).
        where(:areacode => @cn).
        where(:type => @type)

    all_probes = Probe.
        where(:state => @states).
        where(:areacode => @cn).
        where(:type => @type)

    fixed_schedules = Schedule.
        where(:destination_id => fixed_probes)

    mobile_schedules = Schedule.
        where(:destination_id => mobile_probes)

    all_schedules = Schedule.
        where(:destination_id => all_probes)

    mnth = Time.parse(@month).month
    @report_results = {}
    #
    #  SCM4
    #
    @medians_scm4 = Median.
        where('start_timestamp >= ?', mnth.beginning_of_month).
        where('end_timestamp <= ?', mnth.end_of_month).
        where(:schedule_id => fixed_schedules).
        where(:threshold_id => 1).
        order('start_timestamp ASC').all
    #
    # SMP10
    #
    @medians_smp10 = Median.
        where('start_timestamp >= ?', mnth.beginning_of_month).
        where('end_timestamp <= ?', mnth.end_of_month).
        where(:schedule_id => mobile_schedules).
        where(:threshold_id => 1).
        order('start_timestamp ASC').all
    #
    # SCM5
    #
    @medians_scm5 = Median.
        where('start_timestamp >= ?', mnth.beginning_of_month).
        where('end_timestamp <= ?', mnth.end_of_month).
        where(:schedule_id => fixed_schedules).
        where(:threshold_id => 2).
        order('start_timestamp ASC').all

    #
    # SMP11
    #
    @medians_smp11 = Median.
        where('start_timestamp >= ?', mnth.beginning_of_month).
        where('end_timestamp <= ?', mnth.end_of_month).
        where(:schedule_id => mobile_schedules).
        where(:threshold_id => 2).
        order('start_timestamp ASC').all

    #
    # SCM6
    #
    @medians_scm6 = Median.
        where('start_timestamp >= ?', mnth.beginning_of_month).
        where('end_timestamp <= ?', mnth.end_of_month).
        where(:schedule_id => all_schedules).
        where(:threshold_id => 3).
        order('start_timestamp ASC').all

    #
    # SCM7
    #
    @medians_scm7 = Median.
        where('start_timestamp >= ?', mnth.beginning_of_month).
        where('end_timestamp <= ?', mnth.end_of_month).
        where(:schedule_id => all_schedules).
        where(:threshold_id => 4).
        order('start_timestamp ASC').all

    #
    # SCM8
    #
    @medians_scm8 = Median.
        where('start_timestamp >= ?', mnth.beginning_of_month).
        where('end_timestamp <= ?', mnth.end_of_month).
        where(:schedule_id => all_schedules).
        where(:threshold_id => 5).
        order('start_timestamp ASC').all

    #
    # SCM9
    #
    @medians_scm9 = Median.
        where('start_timestamp >= ?', mnth.beginning_of_month).
        where('end_timestamp <= ?', mnth.end_of_month).
        where(:schedule_id => all_schedules).
        where(:threshold_id => 6).
        order('start_timestamp ASC').all

    %w(scm4, scm5, scm6, scm7, scm8, scm9, smp10, smp11).each do |c|
        @report_results[c.to_sym] = {}
        @report_results[c.to_sym][mnth] = {}
    end

    if Date.current.end_of_month != Date.parse(@month).end_of_month
        end_date = Date.parse(@month).end_of_month.day
    else
        end_date = Date.current.day
    end

    (1..end_date).each do |day|
        beginning_of_day = DateTime.parse(@month).change(:day => day).beginning_of_day
        end_of_day = DateTime.parse(@month).change(:day => day).end_of_day
        
        # SCM4
        count4 = 0
        count_all4 = 0
        @medians_scm4.each do |median|
            if median.start_timestamp >= beginning_of_day && median.start_timestamp <= end_of_day
                unless median.dsavg.nil? || median.sdavg.nil?
                    up = (median.dsavg.to_f / (1000 * median.schedule.destination.plan.throughput_up.to_f)).round(3)
                    down = (median.sdavg.to_f / (1000 * median.schedule.destination.plan.throughput_down.to_f)).round(3)
                    count_all4 += 1
                    if down >= median.threshold.goal_level.round(3) && up >= median.threshold.goal_level.round(3)
                        count4 += 1
                    end
                end
            end
        end
        @report_results[:scm4][mnth][day.to_s] = {}
        count_all4 != 0 ? @report_results[:scm4][mnth][day.to_s][:total] = ((count4 / count_all4) * 100).to_f.round(2): @report_results[:scm4][mnth][day.to_s][:total] = 0.0

        # SPM10
        count10 = 0
        count_all10 = 0
        @medians_smp10.each do |median|
            if median.start_timestamp >= beginning_of_day && median.start_timestamp <= end_of_day
                unless median.dsavg.nil? || median.sdavg.nil?
                    up = (median.dsavg.to_f / (1000 * median.schedule.destination.plan.throughput_up.to_f)).round(3)
                    down = (median.sdavg.to_f / (1000 * median.schedule.destination.plan.throughput_down.to_f)).round(3)
                    count_all10 += 1
                    if down >= median.threshold.goal_level.round && up >= median.threshold.goal_level.round(3)
                        count10 += 1
                    end
                end
            end
        end
        @report_results[:smp10][mnth][day.to_s] = {}
        count_all10 != 0 ? @report_results[:smp10][mnth][day.to_s][:total] = ((count10 / count_all10) * 100).to_f.round(2) : @report_results[:smp10][mnth][day.to_s][:total] = 0.0

        # SCM5
        down = 0
        up = 0
        count_all5 = 0
        @medians_scm5.each do |median|
            if median.start_timestamp >= beginning_of_day && median.start_timestamp <= end_of_day
                unless median.dsavg.nil? || median.sdavg.nil?
                    up = up + (median.dsavg.to_f / (1000 * median.schedule.destination.plan.throughput_up.to_f)).round(3)
                    down = down + (median.sdavg.to_f / (1000 * median.schedule.destination.plan.throughput_down.to_f)).round(3)
                    count_all5 += 1
                end
            end
        end
        @report_results[:scm5][mnth][day.to_s] = {}
        count_all5 != 0 ? @report_results[:scm5][mnth][day.to_s][:total_down] = ((down / count_all5) * 100).to_f.round(2) : @report_results[:scm5][day.to_s][:total_down] = 0.0
        count_all5 != 0 ? @report_results[:scm5][mnth][day.to_s][:total_up] = ((up / count_all5) * 100).to_f.round(2) : @report_results[:scm5][day.to_s][:total_up] = 0.0

        # SMP11
        down = 0
        up = 0
        count_all11 = 0
        @medians_smp11.each do |median|
            if median.start_timestamp >= beginning_of_day && median.start_timestamp <= end_of_day
                unless median.dsavg.nil? || median.sdavg.nil?
                    up = up + (median.dsavg.to_f / (1000 * median.schedule.destination.plan.throughput_up.to_f)).round(3)
                    down = down + (median.sdavg.to_f / (1000 * median.schedule.destination.plan.throughput_down.to_f)).round(3)
                    count_all11 += 1
                end
            end
        end
        @report_results[:smp11][mnth][day.to_s] = {}
        count_all11 != 0 ? @report_results[:smp11][mnth][day.to_s][:total_down] = ((down / count_all11) * 100).to_f.round(2) : @report_results[:smp11][mnth][day.to_s][:total_down] = 0.0
        count_all11 != 0 ? @report_results[:smp11][mnth][day.to_s][:total_up] = ((up / count_all11) * 100).to_f.round(2) : @report_results[:smp11][mnth][day.to_s][:total_up] = 0.0

        # SCM6
        count6 = 0
        count_all6 = 0
        @medians_scm6.each do |median|
            if median.start_timestamp >= beginning_of_day && median.start_timestamp <= end_of_day
                unless median.dsavg.nil?
                    up = median.dsavg.to_f * 1000
                    count_all6 += 1
                    if up <= median.threshold.goal_level.round(3)
                        count6 += 1
                    end
                end
            end
        end
        @report_results[:scm6][mnth][day.to_s] = {}
        count_all6 != 0 ? @report_results[:scm6][mnth][day.to_s][:total] = ((count6 / count_all6) * 100).to_f.round(2) : @report_results[:scm6][mnth][day.to_s][:total] = 0.0

        # SCM7
        count7 = 0
        count_all7 = 0
        @medians_scm7.each do |median|
            if median.start_timestamp >= beginning_of_day && median.start_timestamp <= end_of_day
                unless median.dsavg.nil? || median.sdavg.nil?
                    down = median.sdavg.to_f * 1000
                    up =  median.dsavg.to_f * 1000
                    count_all7 += 1
                    if down <= median.threshold.goal_level.round(3) && up <= median.threshold.goal_level.round(3)
                        count7 += 1
                    end
                end
            end
        end
        @report_results[:scm7][mnth][day.to_s] = {}
        count_all7 != 0 ? @report_results[:scm7][mnth][day.to_s][:total] = ((count7 / count_all7) * 100).to_f.round(2) : @report_results[:scm7][mnth][day.to_s][:total] = 0.0

        # SCM8
        count8 = 0
        count_all8 = 0
        @medians_scm8.each do |median|
            if median.start_timestamp >= beginning_of_day && median.start_timestamp <= end_of_day
                unless  median.sdavg.nil?
                    down = median.sdavg.to_f
                    count_all8 += 1
                    if down <= median.threshold.goal_level.round(3)
                        count8 += 1
                    end
                end
            end
        end
        @report_results[:scm8][mnth][day.to_s] = {}
        count_all8 != 0 ? @report_results[:scm8][mnth][day.to_s][:total] = ((count8 / count_all8) * 100).to_f.round(2) : @report_results[:scm8][mnth][day.to_s][:total] = 0.0

        # SCM9
        points = 0
        total_points = 0
        @medians_scm9.each do |median|
            if median.start_timestamp >= beginning_of_day && median.start_timestamp <= end_of_day
                points = points + median.expected_points
                total_points = total_points + median.total_points
            end
        end
        @report_results[:scm9][mnth][day.to_s] = {}
        points != 0 ? @report_results[:scm9][mnth][day.to_s][:total] = ((total_points / points) * 100).to_f.round(2) : @report_results[:scm9][mnth][day.to_s][:total] = 0.0


    end

    respond_to do |format|
      format.html  {render :layout=> false}
    end

  end


  def detail_speed_type_eaq2_table
   #consolidacao pela velocidade contratada
   #consolidacao por tipo de agente e tecnologia de conexão
    @date = params[:date]
    @id = params[:id]
    @type = params[:agent] # android or linux
    agent_type = params[:agent_type] # fixed or mobile, if linux
    states = params[:state]
    @cn = params[:cn]
    @goal_filter = params[:goal_filter] #all,above or under

    states.delete("")

    if @type == "android"
        agent_type = ["fixed", "mobile"]
    end

    if @goal_filter.include?("above") && @goal_filter.include?("under")
        goal_query = ""
    else
        if @goal_filter[0] == "above"
            goal_query = "medians.sdavg >= thresholds.compliance_level"
        else
            goal_query = "medians.sdavg < thresholds.compliance_level"
        end
    end

    @plans = Plan.all

    @results = {}

    @plans.each do |plan|
        @results[plan.id] = {}
        if @type.include? "linux"
            @results[plan.id][:linux] = {}

            if agent_type.include? "fixed"
                @results[plan.id][:linux][:fixed] = []
                probes = Probe.
                    where(:connection_profile_id => ConnectionProfile.where(:conn_type => "fixed")).
                    where(:type => "linux").
                    where(:plan_id => plan.id).
                    where(:state => states).
                    where(:areacode => @cn).all

                schedules = Schedule.
                    where(:destination_id => probes).all

                @results[plan.id][:linux][:fixed] << Median.
                    where('start_timestamp >= ?', DateTime.parse(@date).beginning_of_day).
                    where('end_timestamp <= ?', DateTime.parse(@date).end_of_day).
                    where(:schedule_id => schedules).
                    joins(:threshold).where(goal_query).
                    order('start_timestamp ASC').all
            end
            if agent_type.include? "mobile"
                @results[plan.id][:linux][:mobile] = []
                probes = Probe.
                    where(:connection_profile_id => ConnectionProfile.where(:conn_type => "mobile")).
                    where(:type => "linux").
                    where(:plan_id => plan.id).
                    where(:state => states).
                    where(:areacode => @cn).all

                schedules = Schedule.
                    where(:destination_id => probes).all

                @results[plan.id][:linux][:mobile] << Median.
                    where('start_timestamp >= ?', DateTime.parse(@date).beginning_of_day).
                    where('end_timestamp <= ?', DateTime.parse(@date).end_of_day).
                    where(:schedule_id => schedules).
                    joins(:threshold).where(goal_query).
                    order('start_timestamp ASC').all
            end
        end
        if @type.include? "android"
            @results[plan.id][:android] = []

            probes = Probe.
                where(:type => "android").
                where(:plan_id => plan.id).
                where(:state => states).
                where(:areacode => @cn).all

            schedules = Schedule.
                where(:destination_id => probes).all

            @results[plan.id][:android] << Median.
                where('start_timestamp >= ?', DateTime.parse(@date).beginning_of_day).
                where('end_timestamp <= ?', DateTime.parse(@date).end_of_day).
                where(:schedule_id => schedules).
                joins(:threshold).where(goal_query).
                order('start_timestamp ASC').all
        end
    end

    respond_to do |format|
      format.html {render :layout => false}
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
    results = []

    case reference_metric
      when 'throughput'
        graph_threshold = {
            :download => (destination.plan[reference_metric+'_down']*1000) * threshold.goal_level,
            :upload =>  (destination.plan[reference_metric+'_up']*1000) * threshold.goal_level,
        }

        raw_medians.each do |raw_median|
          results << {
              :x => raw_median.start_timestamp.midnight,
              :dsavg => raw_median.dsavg,
              :sdavg => raw_median.sdavg
          }
        end
      when 'rtt'
        graph_threshold = {
            :rtt => threshold.goal_level * 0.001
        }

        raw_medians.each do |raw_median|
          results << {
              :x => raw_median.start_timestamp.midnight,
              :y => raw_median.dsavg
          }
        end
      when 'loss'
        graph_threshold = {
            :perda => threshold.goal_level
        }

        raw_medians.each do |raw_median|
          results << {
              :x => raw_median.start_timestamp,
              :y => raw_median.dsavg
          }
        end
      when 'jitter'
        graph_threshold = {
            :jitter => threshold.goal_level * 0.001
        }

        raw_medians.each do |raw_median|
          results << {
              :x => raw_median.start_timestamp.midnight,
              :dsavg => raw_median.dsavg,
              :sdavg => raw_median.sdavg
          }
        end
      else
        graph_threshold = {
            :download => threshold.goal_level,
            :upload =>  threshold.goal_level,
        }

        raw_medians.each do |raw_median|
          results << {
              :x => raw_median.start_timestamp.midnight,
              :dsavg => raw_median.dsavg,
              :sdavg => raw_median.sdavg
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

    from = DateTime.parse(params[:date][:start]+' '+params[:time][:start]+' '+DateTime.current.zone).beginning_of_month.in_time_zone('GMT')
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

  def csv_bruto
    source = Probe.find(params[:source])
    destination = Probe.find(params[:destination])
    metric = Metric.find(params[:metric])
    schedule = Schedule.where(:destination_id => destination).where(:source_id => source).all.last

    from = params[:from]
    to = params[:to]

    raw_results = Results.
        where(:schedule_id => schedule.id).
        where(:metric_id => metric.id).
        where(:timestamp => from..to).order('timestamp ASC').all

    @end_csv = CSV.generate(col_sep: ';') do |csv|
	  csv << ["Sonda de Destino:", destination.pretty_name, "#{destination.city}/#{destination.state}"]
	  csv << ["Sonda de Origem:", source.pretty_name, "#{source.city}/#{source.state}"]
	  csv << ["Métrica:", metric.name, "Formato:", metric.db_unit]
	  csv << ["Início:", schedule.start.strftime("%Y-%m-%d %H:%M:%S %z")]
	  csv << ["Fim:", schedule.end.strftime("%Y-%m-%d %H:%M:%S %z")]
	  csv << [] # Linha em branco pra ficar bonito

      raw_results.each do |result|
		csv << [result.sdavg, result.dsavg, result.sdmax, result.dsmax, result.sdmin, result.dsmin, result.timestamp.strftime("%Y-%m-%d %H:%M:%S %z")]
	  end
    end

	respond_to do |format|
      format.csv { send_data @end_csv}
    end
  end

  def xls_bruto
    @source = Probe.find(params[:source])
    @destination = Probe.find(params[:destination])
    @metric = Metric.find(params[:metric])
    @schedule = Schedule.where(:destination_id => @destination).where(:source_id => @source).all.last

    @from = params[:from]
    @to = params[:to]

    @raw_results = Results.
        where(:schedule_id => @schedule.id).
        where(:metric_id => @metric.id).
        where(:timestamp => @from..@to).order('timestamp ASC').all

	respond_to do |format|
		format.xls
	end
  end

  def csv_mensal
	  source = Probe.find(params[:source])
	  destination = Probe.find(params[:destination])
	  threshold = Threshold.find(params[:threshold])
	  schedule = Schedule.where(:destination_id => destination).where(:source_id => source).all.last

	  from = DateTime.parse(params[:from]).beginning_of_month.in_time_zone('GMT')
	  to = DateTime.parse(params[:to]).end_of_day.in_time_zone('GMT')

	  compliances = Compliance.
		  where(:schedule_id => schedule.id).
		  where(:threshold_id => threshold.id).
		  where('start_timestamp >= ?', from).
		  where('end_timestamp <= ?', to).order('start_timestamp ASC').all

	  @end_csv = CSV.generate(col_sep: ';') do |csv|
		  csv << ["Sonda de Destino:", destination.pretty_name, "#{destination.city}/#{destination.state}"]
		  csv << ["Sonda de Origem:", source.pretty_name, "#{source.city}/#{source.state}"]
		  csv << ["Métrica:", threshold.metric.name, "Meta:", threshold.name]
		  csv << ["Início:", schedule.start.strftime("%Y-%m-%d %H:%M:%S %z")]
		  csv << ["Fim:", schedule.end.strftime("%Y-%m-%d %H:%M:%S %z")]
		  csv << [] # Linha em branco pra ficar bonito

		  csv << ["Timestamp Início", "Timestamp Fim", "Download", "Upload", "Dias Esperados", "Dias Totais"]
		  compliances.each do |compliance|
			  csv << [compliance.start_timestamp, compliance.end_timestamp, compliance.download, compliance.upload, compliance.expected_days, compliance.total_days]
		  end
	  end

	  respond_to do |format|
		  format.csv { send_data @end_csv}
	  end
  end

  def xls_mensal
	  @source = Probe.find(params[:source])
	  @destination = Probe.find(params[:destination])
	  @threshold = Threshold.find(params[:threshold])
	  @schedule = Schedule.where(:destination_id => @destination).where(:source_id => @source).all.last

	  @from = DateTime.parse(params[:from]).beginning_of_month.in_time_zone('GMT')
	  @to = DateTime.parse(params[:to]).end_of_day.in_time_zone('GMT')

	  @compliances = Compliance.
		  where(:schedule_id => @schedule.id).
		  where(:threshold_id => @threshold.id).
		  where('start_timestamp >= ?', @from).
		  where('end_timestamp <= ?', @to).order('start_timestamp ASC').all

	  respond_to do |format|
		  format.xls
	  end
  end

  def csv_diario
	  source = Probe.find(params[:source])
	  destination = Probe.find(params[:destination])
	  threshold = Threshold.find(params[:threshold])
	  schedule = Schedule.where(:destination_id => destination).where(:source_id => source).all.last

	  from = DateTime.parse(params[:from]).beginning_of_month.in_time_zone('GMT')
	  to = DateTime.parse(params[:to]).end_of_day.in_time_zone('GMT')

	  medians = Median.
		  where(:schedule_id => schedule.id).
		  where(:threshold_id => threshold.id).
		  where('start_timestamp >= ?', from).
		  where('end_timestamp <= ?', to).order('start_timestamp ASC').all

	  @end_csv = CSV.generate(col_sep: ';') do |csv|
		  csv << ["Sonda de Destino:", destination.pretty_name, "#{destination.city}/#{destination.state}"]
		  csv << ["Sonda de Origem:", source.pretty_name, "#{source.city}/#{source.state}"]
		  csv << ["Métrica:", threshold.metric.name, "Meta:", threshold.name]
		  csv << ["Início:", schedule.start.strftime("%Y-%m-%d %H:%M:%S %z")]
		  csv << ["Fim:", schedule.end.strftime("%Y-%m-%d %H:%M:%S %z")]
		  csv << [] # Linha em branco pra ficar bonito

		  csv << ["Timestamp Início", "Timestamp Fim", "Pontos Esperados", "Pontos Totais", "DSAVG", "SDAVG"]
		  medians.each do |median|
			csv << [median.start_timestamp, median.end_timestamp, median.expected_points, median.total_points, median.dsavg, median.sdavg]
		  end
	  end

	  respond_to do |format|
		  format.csv { send_data @end_csv}
	  end
  end

  def xls_diario
	  @source = Probe.find(params[:source])
	  @destination = Probe.find(params[:destination])
	  @threshold = Threshold.find(params[:threshold])
	  @schedule = Schedule.where(:destination_id => @destination).where(:source_id => @source).all.last

	  @from = DateTime.parse(params[:from]).beginning_of_month.in_time_zone('GMT')
	  @to = DateTime.parse(params[:to]).end_of_day.in_time_zone('GMT')

	  @medians = Median.
		  where(:schedule_id => @schedule.id).
		  where(:threshold_id => @threshold.id).
		  where('start_timestamp >= ?', @from).
		  where('end_timestamp <= ?', @to).order('start_timestamp ASC').all
	  
	  respond_to do |format|
		  format.xls
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
      format.xls
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

  # Send é chamado pela sonda para enviar reports novos
  def send_report
	report = Nokogiri::XML(params[:report])

	user = report.xpath("report/user").children.to_s
	uuid = SecureRandom.uuid # Nao estamos mandando um UUID de verdade ainda no XML.
	timestamp = report.xpath("report/timestamp").children.to_s
	agent_type = report.xpath("report/agent_type").children.to_s

    case agent_type
    when "windows"
        # KPI
        cell_id = report.xpath("report/kpis/cell_id").children.first.to_s
        cell_id = nil if cell_id == "-"
        
        model = report.xpath("report/kpis/model").children.first.to_s
        model = nil if model == "-"

        conn_tech = report.xpath("report/kpis/conn_tech").children.first.to_s
        conn_tech = nil if conn_tech == "-"

        conn_type = report.xpath("report/kpis/conn_type").children.first.to_s
        conn_type = nil if conn_type == "-"

        error_rate = report.xpath("report/kpis/error_rate").children.first.to_s
        error_rate = nil if error_rate == "-"

        lac = report.xpath("report/kpis/lac").children.first.to_s
        if lac == "-"
            lac = nil
        else
            lac = lac.to_i
        end
            
        mtu = report.xpath("report/kpis/mtu").children.first.to_s
        if mtu == "-"
            mtu = nil
        else
            mtu = mtu.to_i
        end

        route = report.xpath("report/kpis/route").children.first.to_s
        route = nil if route == "-"

        @kpi = Kpi.create(schedule_uuid: uuid,
                          uuid: SecureRandom.uuid,
                          cell_id: cell_id,
                          model: model,
                          conn_tech: conn_tech,
                          conn_type: conn_type,
                          error_rate: error_rate,
                          lac: lac,
                          mtu: mtu
                         )

        # Results
        rtt                        = report.xpath("report/results/rtt").children.first.to_s.to_f
        throughput_udp_down        = report.xpath("report/results/throughput_udp/down").children.first.to_s.to_f
        throughput_udp_up          = report.xpath("report/results/throughput_udp/up").children.first.to_s.to_f
        throughput_tcp_down        = report.xpath("report/results/throughput_tcp/down").children.first.to_s.to_f
        throughput_tcp_up          = report.xpath("report/results/throughput_tcp/up").children.first.to_s.to_f
        throughput_http_down       = report.xpath("report/results/throughput_http/down").children.first.to_s.to_f
        throughput_http_up         = report.xpath("report/results/throughput_http/up").children.first.to_s.to_f
        jitter_down                = report.xpath("report/results/jitter/down").children.first.to_s.to_f
        jitter_up                  = report.xpath("report/results/jitter/up").children.first.to_s.to_f
        loss_down                  = report.xpath("report/results/loss/down").children.first.to_s.to_f
        loss_up                    = report.xpath("report/results/loss/up").children.first.to_s.to_f
        pom_down                   = report.xpath("report/results/pom/down").children.first.to_s.to_i
        pom_up                     = report.xpath("report/results/pom/up").children.first.to_s.to_i
        dns_efic                   = report.xpath("report/results/dns/efic").children.first.to_s.to_i
        dns_timeout_errors         = report.xpath("report/results/dns/errors/timeout").children.first.to_s.to_i
        dns_server_failure_errors  = report.xpath("report/results/dns/errors/server_failure").children.first.to_s.to_i

        @dynamic_result = DynamicResult.create(rtt: rtt,
                                               throughput_udp_down: throughput_udp_down,
                                               throughput_udp_up: throughput_udp_up,
                                               throughput_tcp_down: throughput_tcp_down,
                                               throughput_tcp_up: throughput_tcp_up,
                                               throughput_http_down: throughput_http_down,
                                               throughput_http_up: throughput_http_up,
                                               jitter_down: jitter_down,
                                               jitter_up: jitter_up,
                                               loss_down: loss_down,
                                               loss_up: loss_up,
                                               pom_down: pom_down,
                                               pom_up: pom_up,
                                               uuid: uuid,
                                               dns_efic: dns_efic,
                                               dns_timeout_errors: dns_timeout_errors,
                                               dns_server_failure_errors: dns_server_failure_errors,
                                               user: user
                                              )

        # DNS test results
        dns_server = dns_url = dns_delay = nil
        @dns_dynamic_results = []
        report.xpath("report/results/dns").children.each do |c|
            if c.name == "test"
                c.children.each do |cc|
                    case cc.name
                    when "server"
                        dns_server = cc.children.first.to_s
                    when "url"
                        dns_url = cc.children.first.to_s
                    when "delay" 
                        dns_delay = cc.children.first.to_s.to_f
                    end
                end

                @dns_dynamic_results << DnsDynamicResult.create(server: dns_server,
                                                              url: dns_url,
                                                              delay: dns_delay,
                                                              uuid: uuid
                                                             )
            end
        end

        # Web Load test results
        web_load_url = web_load_time = web_load_size = web_load_throughput = nil
        @web_load_dynamic_results = []
        report.xpath("report/results/web_load").children.each do |c|
            if c.name == "test"
                c.children.each do |cc|
                    case cc.name
                    when "url"
                        web_load_url = cc.children.first.to_s
                    when "time"
                        web_load_time = cc.children.first.to_s.to_f
                    when "size"
                        web_load_size = cc.children.first.to_s.to_f
                    when "throughput"
                        web_load_throughput = cc.children.first.to_s.to_f
                    end
                end

                @web_load_dynamic_results << WebLoadDynamicResult.create(url: web_load_url,
                                                                       time: web_load_time,
                                                                       size: web_load_size,
                                                                       throughput: web_load_throughput,
                                                                       uuid: uuid
                                                                      )
            end
        end

    when /linux|android/
        @rep = Report.create(user: user, uuid: uuid, timestamp: DateTime.strptime(timestamp, '%s'), agent_type: agent_type)

        results = report.xpath("report/results").children

        results.each do |result|
            case result.name	
            when "availability"
                total = result.xpath("total").children.text.to_i
                success = result.xpath("success").children.text.to_i

                @probe = Probe.find_by_ipaddress(user)
                @schedule = @probe.schedules.last

                @metric = Metric.find_by_plugin("availability")

                @threshold = Threshold.find_by_goal_method("availability")

                @median = Median.new(schedule_uuid: @schedule.uuid,
                                     start_timestamp: (DateTime.strptime(timestamp, '%s') - 23.hours - 59.minutes - 59.seconds),
                                     end_timestamp: DateTime.strptime(timestamp, '%s'),
                                     expected_points: total,
                                     total_points: success,
                                     dsavg: success.to_f/total.to_f
                                    )
                @median.schedule = @schedule
                @median.threshold = @threshold

                @median.save
            when "web_load"
                url = time = size = throughput = time_main_domain = size_main_domain = throughput_main_domain = time_other_domain = size_other_domain = throughput_other_domain = nil
                @web_load_results = []
                report.xpath("report/results/web_load").children.each do |c|
                    if c.name == "test"
                        c.children.each do |cc|
                            case cc.name
                            when "url"
                                url = cc.children.first.to_s
                            when "time"
                                time = cc.children.first.to_s.to_f
                            when "size"
                                size = cc.children.first.to_s.to_i
                            when "throughput"
                                throughput = cc.children.first.to_s.to_f
                            when "time_main_domain"
                                time_main_domain = cc.children.first.to_s.to_f
                            when "size_main_domain"
                                size_main_domain = cc.children.first.to_s.to_i
                            when "throughput_main_domain"
                                throughput_main_domain = cc.children.first.to_s.to_f 
                            when "time_other_domain"
                                time_other_domain = cc.children.first.to_s.to_f 
                            when "size_other_domain"
                                size_other_domain = cc.children.first.to_s.to_i 
                            when "throughput_other_domain"
                                throughput_other_domain = cc.children.first.to_s.to_f 
                            end
                            @web_load_results << WebLoadResult.create(url: url,
                                                                      time: time,
                                                                      size: size,
                                                                      throughput: throughput,
                                                                      time_main_domain: time_main_domain,
                                                                      size_main_domain: size_main_domain,
                                                                      throughput_main_domain: throughput_main_domain,
                                                                      time_other_domain: time_other_domain,
                                                                      size_other_domain: size_other_domain,
                                                                      throughput_other_domain: throughput_other_domain,
                                                                      uuid: uuid
                                                                     )
                        end
                    end
                end
            when "dns"
                server = url = delay = nil
                efic = average = timeout_errors = server_failure_errors = nil
                report.xpath("report/results/dns").children.each do |c|
                    case c.name
                    when "test"
                        @dns_results = []
                        c.children.each do |cc|
                            case cc.name
                            when "server"
                                server = cc.children.first.to_s
                            when "url"
                                url = cc.children.first.to_s
                            when "delay"
                                delay = cc.children.first.to_s.to_i
                            end
                            @dns_results << DnsResult.create(url: url,
                                                             server: server,
                                                             delay: delay,
                                                             uuid: uuid
                                                            )
                        end
                    when efic
                        efic = c.children.first.to_s.to_f
                    when media
                        efic = c.children.first.to_s.to_f
                    when errors
                        c.children.each do |cc|
                            case cc.name
                            when "timeout"
                                timeout_errors = cc.children.first.to_s.to_i
                            when "server_failures"
                                server_failure_errors = cc.children.first.to_s.to_i
                            else
                                # do nothing
                            end
                        end
                    else
                        # Do nothing
                    end
                end
                @dns_detail = DnsDetail.create(efic: efic,
                                               average: average,
                                               timeout_errors: timeout_errors,
                                               server_failure_errors: server_failure_errors,
                                               uuid: uuid
                                              )
            when "throughput_http"
                throughput_http_down = report.xpath("report/results/throughput_http/down").to_s.to_f
                throughput_http_up = report.xpath("report/results/throughput_http/up").to_s.to_f

                metric = Metric.where(plugin: "throughput_http")
                probe = Probe.where(name: name)
                schedule = probe.schedules_as_destination.last

                @results = Results.create(schedule_id: schedule.id,
                                          metric_id: metric.id,
                                          schedule_uuid: schedule.uuid,
                                          uuid: uuid,
                                          metric_name: "throughput_http",
                                          timestamp: timestamp,
                                          sdavg: throughput_http_down,
                                          dsavg: throughput_http_up
                                         )
            else
                # do nothing
            end
        end
    else
        # do nothing
    end

	respond_to do |format|
		format.xml { render xml: "<report><status>OK</status></report>" }
	end
  end

end
