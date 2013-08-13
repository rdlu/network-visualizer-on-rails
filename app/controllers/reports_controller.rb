# coding: utf-8
class ReportsController < ApplicationController
  def index
    @report_types = [
        ['Gráfico de Indicadores Anatel/EAQ - Consolidação Diária', 'eaq_graph'],
        ['Gráfico de Indicadores Anatel/EAQ - Consolidação Mensal', 'eaq_compliance_graph'],
        ['Gráfico de Dados Brutos', 'graph'],
        ['Tabela de Indicadores Anatel/EAQ', 'eaq_table']
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
            :extra => {:uuid => raw_result.uuid}
        }
      end
    else
      raw_results.each do |raw_result|
        results << {
            :x => raw_result.timestamp,
            :dsavg => raw_result.dsavg,
            :dsmin => raw_result.dsmin,
            :dsmax => raw_result.dsmax,
            :extra => {:uuid => raw_result.uuid}
        }
      end
    end

    data = {
        :source => source,
        :destination => destination,
        :metric => metric,
        :schedule => schedule,
        :range => {:start => from, :end => to},
        :results => results
    }

    respond_to do |format|
      format.json { render :json => data, :status => 200 }
    end
  end

  def eaq2_table
    @uid = SecureRandom.uuid #id necessario para div
    @from = DateTime.parse(params[:date][:start])
    @to = DateTime.parse(params[:date][:end])
    @months = @from.all_months_until @to
    @type = params[:agent] # android or linux
    @agent_type = params[:agent_type] # fixed or mobile, if linux
    @states = params[:state]
    @cn = params[:cn]
    @goal_filter = params[:goal_filter] #all,above or under
    @pop = params[:pop]
    @bras = params[:bras]


    if @type.include? "android"
      @agent_type = ["fixed", "mobile"]
    end

    if @type.include? "all"
      @type = ["android","linux"]
      @agent_type = ["fixed", "mobile"]
    end


    if @agent_type.nil?
      @agent_type = ["fixed", "mobile"]
    end

    if @goal_filter.nil?
      @goal_filter = false
    end

    # Garantir que não tenhamos nulos
    @cn.delete("")
    @states.delete("")

    if @agent_type.include? 'fixed'
      fixed_conn_profile = ConnectionProfile.
        where(:conn_type => "fixed")
    else
      fixed_conn_profile = nil
    end

    if @agent_type.include? 'mobile'
      mobile_conn_profile = ConnectionProfile.
        where(:conn_type => "mobile")
    else
      mobile_conn_profile = nil
    end

    if !(@pop.include? 'all') && !(@bras.include? 'all')
      fixed_probes = Probe.
        where(:connection_profile_id => fixed_conn_profile).
        where(:state => @states).
        where(:areacode => @cn).
        where(:type => @type).
        where(:anatel => @goal_filter).
        where(:pop => @pop).
        where(:bras => @bras)

    mobile_probes = Probe.
        where(:connection_profile_id => mobile_conn_profile).
        where(:state => @states).
        where(:areacode => @cn).
        where(:type => @type).
        where(:anatel => @goal_filter).
        where(:pop => @pop).
        where(:bras => @bras)

    else if (@pop.include? 'all') && (@bras.include? 'all')
       fixed_probes = Probe.
        where(:connection_profile_id => fixed_conn_profile).
        where(:state => @states).
        where(:areacode => @cn).
        where(:type => @type).
        where(:anatel => @goal_filter)

      mobile_probes = Probe.
        where(:connection_profile_id => mobile_conn_profile).
        where(:state => @states).
        where(:areacode => @cn).
        where(:type => @type).
        where(:anatel => @goal_filter)

      all_probes = Probe.
          where(:state => @states).
          where(:areacode => @cn).
          where(:type => @type).
          where(:anatel => @goal_filter)
      else if @pop.include? 'all'
           fixed_probes = Probe.
               where(:connection_profile_id => fixed_conn_profile).
               where(:state => @states).
               where(:areacode => @cn).
               where(:type => @type).
               where(:anatel => @goal_filter).
               where(:bras => @bras)

           mobile_probes = Probe.
               where(:connection_profile_id => mobile_conn_profile).
               where(:state => @states).
               where(:areacode => @cn).
               where(:type => @type).
               where(:anatel => @goal_filter).
               where(:bras => @bras)

           all_probes = Probe.
               where(:state => @states).
               where(:areacode => @cn).
               where(:type => @type).
               where(:anatel => @goal_filter).
               where(:bras => @bras)

         else if @bras.include? 'all'
           fixed_probes = Probe.
               where(:connection_profile_id => fixed_conn_profile).
               where(:state => @states).
               where(:areacode => @cn).
               where(:type => @type).
               where(:anatel => @goal_filter).
               where(:pop => @pop)

           mobile_probes = Probe.
               where(:connection_profile_id => mobile_conn_profile).
               where(:state => @states).
               where(:areacode => @cn).
               where(:type => @type).
               where(:anatel => @goal_filter).
               where(:pop => @pop)

           all_probes = Probe.
               where(:state => @states).
               where(:areacode => @cn).
               where(:type => @type).
               where(:anatel => @goal_filter).
               where(:pop => @pop)
              end
         end
      end
    end




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
      count_all4 != 0 ? @report_results[:scm4][month.to_s][:total] = ((count4 / count_all4) * 100).to_f.round(2) : @report_results[:scm4][month.to_s][:total] = 0.0

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
            down = down + (median.sdavg.to_f / (1000 * median.schedule.destination.plan.throughput_down.to_f)).round(3)
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
            up = median.dsavg.to_f * 1000
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
      format.html { render :layout => false }
    end

  end

  def detail_eaq2_table
    @thresholds = Threshold.all
    @month = params[:month]
    @type = params[:type] # android or linux
    @agent_type = params[:agent_type] # fixed or mobile, if linux
    @states = params[:states]
    @cn = params[:cn]
    @goal_filter = params[:goal_filter]
    @pop = params[:pop]
    @bras = params[:bras]


    if @agent_type.include? 'fixed'
      fixed_conn_profile = ConnectionProfile.
          where(:conn_type => "fixed")
    else
      fixed_conn_profile = nil
    end

    if @agent_type.include? 'mobile'
      mobile_conn_profile = ConnectionProfile.
          where(:conn_type => "mobile")
    else
      mobile_conn_profile = nil
    end


    if !(@pop.include? 'all') && !(@bras.include? 'all')
      fixed_probes = Probe.
          where(:connection_profile_id => fixed_conn_profile).
          where(:state => @states).
          where(:areacode => @cn).
          where(:type => @type).
          where(:anatel => @goal_filter).
          where(:pop => @pop).
          where(:bras => @bras)

      mobile_probes = Probe.
          where(:connection_profile_id => mobile_conn_profile).
          where(:state => @states).
          where(:areacode => @cn).
          where(:type => @type).
          where(:anatel => @goal_filter).
          where(:pop => @pop).
          where(:bras => @bras)

    else if (@pop.include? 'all') && (@bras.include? 'all')
           fixed_probes = Probe.
               where(:connection_profile_id => fixed_conn_profile).
               where(:state => @states).
               where(:areacode => @cn).
               where(:type => @type).
               where(:anatel => @goal_filter)

           mobile_probes = Probe.
               where(:connection_profile_id => mobile_conn_profile).
               where(:state => @states).
               where(:areacode => @cn).
               where(:type => @type).
               where(:anatel => @goal_filter)

           all_probes = Probe.
               where(:state => @states).
               where(:areacode => @cn).
               where(:type => @type).
               where(:anatel => @goal_filter)
         else if @pop.include? 'all'
                fixed_probes = Probe.
                    where(:connection_profile_id => fixed_conn_profile).
                    where(:state => @states).
                    where(:areacode => @cn).
                    where(:type => @type).
                    where(:anatel => @goal_filter).
                    where(:bras => @bras)

                mobile_probes = Probe.
                    where(:connection_profile_id => mobile_conn_profile).
                    where(:state => @states).
                    where(:areacode => @cn).
                    where(:type => @type).
                    where(:anatel => @goal_filter).
                    where(:bras => @bras)

                all_probes = Probe.
                    where(:state => @states).
                    where(:areacode => @cn).
                    where(:type => @type).
                    where(:anatel => @goal_filter).
                    where(:bras => @bras)

              else if @bras.include? 'all'
                     fixed_probes = Probe.
                         where(:connection_profile_id => fixed_conn_profile).
                         where(:state => @states).
                         where(:areacode => @cn).
                         where(:type => @type).
                         where(:anatel => @goal_filter).
                         where(:pop => @pop)

                     mobile_probes = Probe.
                         where(:connection_profile_id => mobile_conn_profile).
                         where(:state => @states).
                         where(:areacode => @cn).
                         where(:type => @type).
                         where(:anatel => @goal_filter).
                         where(:pop => @pop)

                     all_probes = Probe.
                         where(:state => @states).
                         where(:areacode => @cn).
                         where(:type => @type).
                         where(:anatel => @goal_filter).
                         where(:pop => @pop)
                   end
              end
         end
    end

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
        where('start_timestamp >= ?', Time.parse(@month).beginning_of_month).
        where('end_timestamp <= ?', Time.parse(@month).end_of_month).
        where(:schedule_id => fixed_schedules).
        where(:threshold_id => 1).
        order('start_timestamp ASC').all
    #
    # SMP10
    #
    @medians_smp10 = Median.
        where('start_timestamp >= ?', Time.parse(@month).beginning_of_month).
        where('end_timestamp <= ?', Time.parse(@month).end_of_month).
        where(:schedule_id => mobile_schedules).
        where(:threshold_id => 1).
        order('start_timestamp ASC').all
    #
    # SCM5
    #
    @medians_scm5 = Median.
        where('start_timestamp >= ?', Time.parse(@month).beginning_of_month).
        where('end_timestamp <= ?', Time.parse(@month).end_of_month).
        where(:schedule_id => fixed_schedules).
        where(:threshold_id => 2).
        order('start_timestamp ASC').all

    #
    # SMP11
    #
    @medians_smp11 = Median.
        where('start_timestamp >= ?', Time.parse(@month).beginning_of_month).
        where('end_timestamp <= ?', Time.parse(@month).end_of_month).
        where(:schedule_id => mobile_schedules).
        where(:threshold_id => 2).
        order('start_timestamp ASC').all

    #
    # SCM6
    #
    @medians_scm6 = Median.
        where('start_timestamp >= ?', Time.parse(@month).beginning_of_month).
        where('end_timestamp <= ?', Time.parse(@month).end_of_month).
        where(:schedule_id => all_schedules).
        where(:threshold_id => 3).
        order('start_timestamp ASC').all

    #
    # SCM7
    #
    @medians_scm7 = Median.
        where('start_timestamp >= ?', Time.parse(@month).beginning_of_month).
        where('end_timestamp <= ?', Time.parse(@month).end_of_month).
        where(:schedule_id => all_schedules).
        where(:threshold_id => 4).
        order('start_timestamp ASC').all

    #
    # SCM8
    #
    @medians_scm8 = Median.
        where('start_timestamp >= ?', Time.parse(@month).beginning_of_month).
        where('end_timestamp <= ?', Time.parse(@month).end_of_month).
        where(:schedule_id => all_schedules).
        where(:threshold_id => 5).
        order('start_timestamp ASC').all

    #
    # SCM9
    #
    @medians_scm9 = Median.
        where('start_timestamp >= ?', Time.parse(@month).beginning_of_month).
        where('end_timestamp <= ?', Time.parse(@month).end_of_month).
        where(:schedule_id => all_schedules).
        where(:threshold_id => 6).
        order('start_timestamp ASC').all

    %w(scm4 scm5 scm6 scm7 scm8 scm9 smp10 smp11).each do |c|
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
      count_all4 != 0 ? @report_results[:scm4][mnth][day.to_s][:total] = ((count4 / count_all4) * 100).to_f.round(2) : @report_results[:scm4][mnth][day.to_s][:total] = 0.0

      # SPM10
      count10 = 0
      count_all10 = 0
      @medians_smp10.each do |median|
        if median.start_timestamp >= beginning_of_day && median.start_timestamp <= end_of_day
          unless median.dsavg.nil? || median.sdavg.nil?
            up = (median.dsavg.to_f / (1000 * median.schedule.destination.plan.throughput_up.to_f)).round(3)
            down = (median.sdavg.to_f / (1000 * median.schedule.destination.plan.throughput_down.to_f)).round(3)
            count_all10 += 1
            if down >= median.threshold.goal_level.round(3) && up >= median.threshold.goal_level.round(3)
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
      count_all5 != 0 ? @report_results[:scm5][mnth][day.to_s][:total_down] = ((down / count_all5) * 100).to_f.round(2) : @report_results[:scm5][mnth][day.to_s][:total_down] = 0.0
      count_all5 != 0 ? @report_results[:scm5][mnth][day.to_s][:total_up] = ((up / count_all5) * 100).to_f.round(2) : @report_results[:scm5][mnth][day.to_s][:total_up] = 0.0

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
            up = median.dsavg.to_f * 1000
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
      format.html { render :layout => false }
    end

  end

  def detail_speed_type_eaq2_table
    #consolidacao pela velocidade contratada
    #consolidacao por tipo de agente e tecnologia de conexão
    @date = params[:date]
    @id = params[:id]
    @type = params[:type] # android or linux
    @agent_type = params[:agent_type] # fixed or mobile, if linux
    @states = params[:states]
    @cn = params[:cn]
    @goal_filter= params[:goal_filter]
    @pop = params[:pop]
    @bras = params[:bras]


    if @agent_type.include? 'fixed'
      fixed_conn_profile = ConnectionProfile.
          where(:conn_type => "fixed")
    else
      fixed_conn_profile = nil
    end

    if @agent_type.include? 'mobile'
      mobile_conn_profile = ConnectionProfile.
          where(:conn_type => "mobile")
    else
      mobile_conn_profile = nil
    end

    @report_results = {}

    %w(scm4 scm5 scm6 scm7 scm8 scm9 smp10 smp11).each do |c|
      @report_results[c.to_sym] = {}
      @report_results[c.to_sym][:download] = {}
      @report_results[c.to_sym][:upload] = {}
    end

    if !(@pop.include? 'all') && !(@bras.include? 'all')
      fixed_probes = Probe.
          where(:connection_profile_id => fixed_conn_profile).
          where(:state => @states).
          where(:areacode => @cn).
          where(:type => @type).
          where(:anatel => @goal_filter).
          where(:pop => @pop).
          where(:bras => @bras)

      mobile_probes = Probe.
          where(:connection_profile_id => mobile_conn_profile).
          where(:state => @states).
          where(:areacode => @cn).
          where(:type => @type).
          where(:anatel => @goal_filter).
          where(:pop => @pop).
          where(:bras => @bras)

    else if (@pop.include? 'all') && (@bras.include? 'all')
           fixed_probes = Probe.
               where(:connection_profile_id => fixed_conn_profile).
               where(:state => @states).
               where(:areacode => @cn).
               where(:type => @type).
               where(:anatel => @goal_filter)

           mobile_probes = Probe.
               where(:connection_profile_id => mobile_conn_profile).
               where(:state => @states).
               where(:areacode => @cn).
               where(:type => @type).
               where(:anatel => @goal_filter)

           all_probes = Probe.
               where(:state => @states).
               where(:areacode => @cn).
               where(:type => @type).
               where(:anatel => @goal_filter)
         else if @pop.include? 'all'
                fixed_probes = Probe.
                    where(:connection_profile_id => fixed_conn_profile).
                    where(:state => @states).
                    where(:areacode => @cn).
                    where(:type => @type).
                    where(:anatel => @goal_filter).
                    where(:bras => @bras)

                mobile_probes = Probe.
                    where(:connection_profile_id => mobile_conn_profile).
                    where(:state => @states).
                    where(:areacode => @cn).
                    where(:type => @type).
                    where(:anatel => @goal_filter).
                    where(:bras => @bras)

                all_probes = Probe.
                    where(:state => @states).
                    where(:areacode => @cn).
                    where(:type => @type).
                    where(:anatel => @goal_filter).
                    where(:bras => @bras)

              else if @bras.include? 'all'
                     fixed_probes = Probe.
                         where(:connection_profile_id => fixed_conn_profile).
                         where(:state => @states).
                         where(:areacode => @cn).
                         where(:type => @type).
                         where(:anatel => @goal_filter).
                         where(:pop => @pop)

                     mobile_probes = Probe.
                         where(:connection_profile_id => mobile_conn_profile).
                         where(:state => @states).
                         where(:areacode => @cn).
                         where(:type => @type).
                         where(:anatel => @goal_filter).
                         where(:pop => @pop)

                     all_probes = Probe.
                         where(:state => @states).
                         where(:areacode => @cn).
                         where(:type => @type).
                         where(:anatel => @goal_filter).
                         where(:pop => @pop)
                   end
              end
         end
    end

    fixed_schedules = Schedule.
        where(:destination_id => fixed_probes).all

    mobile_schedules = Schedule.
        where(:destination_id => mobile_probes).all

    all_schedules = Schedule.
        where(:destination_id => all_probes).all
    #
    #  SCM4
    #
    @medians_scm4 = Median.
        where('start_timestamp >= ?', DateTime.parse(@date).to_date.to_time.beginning_of_day.in_time_zone('GMT')).
        where('start_timestamp <= ?', DateTime.parse(@date).to_date.to_time.end_of_day.in_time_zone('GMT')).
        where(:schedule_id => fixed_schedules).
        where(:threshold_id => 1).
        where("dsavg is not null").
        order('start_timestamp ASC').all
    #
    # SMP10
    #
      @medians_smp10 = Median.
          where('start_timestamp >= ?',  DateTime.parse(@date).to_date.to_time.beginning_of_day.in_time_zone('GMT')).
          where('start_timestamp <= ?',  DateTime.parse(@date).to_date.to_time.end_of_day.in_time_zone('GMT')).
          where(:schedule_id => mobile_schedules).
          where(:threshold_id => 1).
          where("dsavg is not null").
          order('start_timestamp ASC').all
      #
      # SCM5
      #
      @medians_scm5 = Median.
          where('start_timestamp >= ?',  DateTime.parse(@date).to_date.to_time.beginning_of_day.in_time_zone('GMT')).
          where('start_timestamp <= ?',  DateTime.parse(@date).to_date.to_time.end_of_day.in_time_zone('GMT')).
          where(:schedule_id => fixed_schedules).
          where(:threshold_id => 2).
          where("dsavg is not null").
          order('start_timestamp ASC').all

      #
      # SMP11
      #
      @medians_smp11 = Median.
          where('start_timestamp >= ?',  DateTime.parse(@date).to_date.to_time.beginning_of_day.in_time_zone('GMT')).
          where('start_timestamp <= ?',  DateTime.parse(@date).to_date.to_time.end_of_day.in_time_zone('GMT')).
          where(:schedule_id => mobile_schedules).
          where(:threshold_id => 2).
          where("dsavg is not null").
          order('start_timestamp ASC').all

      #
      # SCM6
      #
      @medians_scm6 = Median.
          where('start_timestamp >= ?',  DateTime.parse(@date).to_date.to_time.beginning_of_day.in_time_zone('GMT')).
          where('start_timestamp <= ?',  DateTime.parse(@date).to_date.to_time.end_of_day.in_time_zone('GMT')).
          where(:schedule_id => all_schedules).
          where(:threshold_id => 3).
          where("dsavg is not null").
          order('start_timestamp ASC').all

      #
      # SCM7
      #
      @medians_scm7 = Median.
          where('start_timestamp >= ?',  DateTime.parse(@date).to_date.to_time.beginning_of_day.in_time_zone('GMT')).
          where('start_timestamp <= ?',  DateTime.parse(@date).to_date.to_time.end_of_day.in_time_zone('GMT')).
          where(:schedule_id => all_schedules).
          where(:threshold_id => 4).
          where("dsavg is not null").
          order('start_timestamp ASC').all

      #
      # SCM8
      #
      @medians_scm8 = Median.
          where('start_timestamp >= ?',  DateTime.parse(@date).to_date.to_time.beginning_of_day.in_time_zone('GMT')).
          where('start_timestamp <= ?',  DateTime.parse(@date).to_date.to_time.end_of_day.in_time_zone('GMT')).
          where(:schedule_id => all_schedules).
          where(:threshold_id => 5).
          where("dsavg is not null").
          order('start_timestamp ASC').all

      #
      # SCM9
      #
      @medians_scm9 = Median.
          where('start_timestamp >= ?', DateTime.parse(@date).to_date.to_time.beginning_of_day.in_time_zone('GMT')).
          where('start_timestamp <= ?', DateTime.parse(@date).to_date.to_time.end_of_day.in_time_zone('GMT')).
          where(:schedule_id => all_schedules).
          where(:threshold_id => 6).
          where("dsavg is not null").
          order('start_timestamp ASC').all




    count6 = 0
    count_all6 = 0

    count7 = 0
    count_all7 = 0

    count8 = 0
    count_all8 = 0

    points = 0
    total_points = 0

    Plan.all.each do |plan|
      # Inicializa um hash para cada plano
      %w(scm4 scm5 scm6 scm7 scm8 scm9 smp10 smp11).each do |c|
        @report_results[c.to_sym][:download][plan.throughput_down] = {}
        @report_results[c.to_sym][:upload][plan.throughput_up] = {}
      end
    end


    Plan.all.each do |plan|

      # Armazena valores de cada plano

      media4 = Array.new
      mediaup4 = Array.new

      media5 = Array.new
      mediaup5 = Array.new
      media5up = Array.new
      mediaup5up = Array.new

      media10 = Array.new
      mediaup10 = Array.new

      media11 = Array.new
      mediaup11 = Array.new
      media11up = Array.new
      mediaup11up = Array.new

      #
      # SCM4
      #
      @medians_scm4.each do |median|
          if (!median.dsavg.nil? || !median.sdavg.nil?)
            if median.schedule.destination.plan.throughput_down.eql? plan.throughput_down
              up = (median.dsavg.to_f / (1000 * median.schedule.destination.plan.throughput_up.to_f)).round(3)
              down = (median.sdavg.to_f / (1000 * median.schedule.destination.plan.throughput_down.to_f)).round(3)
              if down >= median.threshold.goal_level.round(3) && up >= median.threshold.goal_level.round(3)
                 media4 << 1
                 mediaup4 << 1
              else
                media4 << 0
                mediaup4 << 0

              end
            end
          end
      end
      @report_results[:scm4][:download][plan.throughput_down]= media4
      @report_results[:scm4][:upload][plan.throughput_up] = mediaup4
      #
      # SMP10
      #
      @medians_smp10.each do |median|
        if !median.dsavg.nil? || !median.sdavg.nil?
          if median.schedule.destination.plan.throughput_down.eql? plan.throughput_down
          up = (median.dsavg.to_f / (1000 * median.schedule.destination.plan.throughput_up.to_f)).round(3)
          down = (median.sdavg.to_f / (1000 * median.schedule.destination.plan.throughput_down.to_f)).round(3)
          if down >= median.threshold.goal_level.round(3) && up >= median.threshold.goal_level.round(3)
            media10 << 1
            mediaup10 << 1

          else
            media10 << 0
            mediaup10 << 0
          end
          end
        end
      end
      @report_results[:smp10][:download][plan.throughput_down] = media10
      @report_results[:smp10][:upload][plan.throughput_up] = mediaup10
      #
      # SCM5
      #
      @medians_scm5.each do |median|
        if (!median.dsavg.nil? || !median.sdavg.nil?)
          if median.schedule.destination.plan.throughput_down.eql? plan.throughput_down
            media5 << (median.sdavg.to_f / (1000 * median.schedule.destination.plan.throughput_down.to_f)).round(3)
            mediaup5 << (median.dsavg.to_f / (1000 * median.schedule.destination.plan.throughput_up.to_f)).round(3)
          end
          if median.schedule.destination.plan.throughput_up.eql? plan.throughput_up
            media5up << (median.sdavg.to_f / (1000 * median.schedule.destination.plan.throughput_down.to_f)).round(3)
            mediaup5up << (median.dsavg.to_f / (1000 * median.schedule.destination.plan.throughput_up.to_f)).round(3)
          end

        end
      end
      @report_results[:scm5][:download][plan.throughput_down]= {:total_up => mediaup5, :total_down => media5}
      @report_results[:scm5][:upload][plan.throughput_up]= {:total_up => mediaup5up, :total_down => media5up}
      #
      # SMP11
      #
      @medians_smp11.each do |median|
        if (!median.dsavg.nil? || !median.sdavg.nil?)
          if median.schedule.destination.plan.throughput_down.eql? plan.throughput_down
            media11 << (median.sdavg.to_f / (1000 * median.schedule.destination.plan.throughput_down.to_f)).round(3)
            mediaup11 << (median.dsavg.to_f / (1000 * median.schedule.destination.plan.throughput_up.to_f)).round(3)
          end
          if median.schedule.destination.plan.throughput_up.eql? plan.throughput_up
            media11up << (median.sdavg.to_f / (1000 * median.schedule.destination.plan.throughput_down.to_f)).round(3)
            mediaup11up << (median.dsavg.to_f / (1000 * median.schedule.destination.plan.throughput_up.to_f)).round(3)
          end
        end
      end
      @report_results[:smp11][:download][plan.throughput_down] = {:total_down => media11, :total_up => mediaup11}
      @report_results[:smp11][:upload][plan.throughput_up] = {:total_up => mediaup11up, :total_down => media11up}

      #
      # SCM6
      #
      @medians_scm6.each do |median|
        if (!median.dsavg.nil? || !median.sdavg.nil?)
            up = median.dsavg.to_f * 1000
            count_all6 += 1
            if up <= median.threshold.goal_level.round(3)
              count6 += 1
            end

        end
      end
      count_all6 != 0? @report_results[:scm6][:download][plan.throughput_down] = ((count6/count_all6)*100).to_f.round(2) : @report_results[:scm6][:download][plan.throughput_down] = 0.0

      #
      # SCM7
      #
      @medians_scm7.each do |median|
        if (!median.dsavg.nil? || !median.sdavg.nil?)
            down = median.sdavg.to_f * 1000
            up = median.dsavg.to_f * 1000
            count_all7 += 1
            if down <= median.threshold.goal_level.round(3) && up <= median.threshold.goal_level.round(3)
              count7 += 1
            end

        end
      end
      count_all7 != 0? @report_results[:scm7][:download][plan.throughput_down] = ((count7/count_all7)*100).to_f.round(2) : @report_results[:scm7][:download][plan.throughput_down] = 0.0
      #
      # SCM8
      #
      @medians_scm8.each do |median|
        if (!median.dsavg.nil? || !median.sdavg.nil?)
            down = median.sdavg.to_f
            count_all8 += 1
            if down <= median.threshold.goal_level.round(3)
              count8 += 1
            end

        end
      end
      count_all8 != 0? @report_results[:scm8][:download][plan.throughput_down] = ((count8/count_all8)*100).to_f.round(2) : @report_results[:scm8][:download][plan.throughput_down] = 0.0
      #
      # SCM9
      #
      @medians_scm9.each do |median|
          if (!median.dsavg.nil? || !median.sdavg.nil?)
              points = points + median.expected_points
              total_points = total_points + median.total_points
          end

      end
      points != 0? @report_results[:scm9][:download][plan.throughput_down] = ((total_points/points)*100).to_f.round(2) : @report_results[:scm9][:download][plan.throughput_down] = 0.0

    end #fim for plan


    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def detail_probe_eaq2_table
    @date = DateTime.parse(params[:date]).to_date.to_time
    @type = params[:type] # android or linux
    @agent_type = params[:agent_type] # fixed or mobile, if linux
    @states = params[:states]
    @cn = params[:cn]
    @goal_filter = params[:goal_filter]
    @pop = params[:pop]
    @bras = params[:bras]

    fixed_conn_profile = ConnectionProfile.
        where(:conn_type => "fixed")

    mobile_conn_profile = ConnectionProfile.
        where(:conn_type => "mobile")


    if !(@pop.include? 'all') && !(@bras.include? 'all')
      @probes = Probe.
          where(:state => @states).
          where(:areacode => @cn).
          where(:type => @type).
          where(:anatel => @goal_filter).
          where(:pop => @pop).
          where(:bras => @bras)

    else if (@pop.include? 'all') && (@bras.include? 'all')
           @probes = Probe.
               where(:state => @states).
               where(:areacode => @cn).
               where(:type => @type).
               where(:anatel => @goal_filter)
         else if @pop.include? 'all'
                @probes = Probe.
                    where(:state => @states).
                    where(:areacode => @cn).
                    where(:type => @type).
                    where(:anatel => @goal_filter).
                    where(:bras => @bras)

              else if @bras.include? 'all'
                     @probes = Probe.
                         where(:state => @states).
                         where(:areacode => @cn).
                         where(:type => @type).
                         where(:anatel => @goal_filter).
                         where(:pop => @pop)
                   end
              end
         end
    end


    unless @agent_type.include?("fixed") && @agent_type.include?("mobile")
        if @agent_type[0] == "fixed"
            @probes = @probes.where(:connection_profile_id => fixed_conn_profile)
        elsif @agent_type[0] == "mobile"
            @probes = @probes.where(:connection_profile_id => mobile_conn_profile)
        end
    end

    @report_results = {}

    @probes.all.each do |probe|
        conn_type = probe.connection_profile.conn_type.to_sym
        probe_type = probe.type.to_sym
        @report_results[conn_type] ||= {}
        @report_results[conn_type][probe_type] ||= {}
        @report_results[conn_type][probe_type][probe.id] = {}

        @report_results[conn_type][probe_type][probe.id][:name] = probe.name
        @report_results[conn_type][probe_type][probe.id][:throughput_down] = probe.plan.throughput_down
        @report_results[conn_type][probe_type][probe.id][:throughput_up] = probe.plan.throughput_up

        %w(scm4 scm5 scm6 scm7 scm8 scm9).each do |c|
          @report_results[conn_type][probe_type][probe.id][c.to_sym] = {}
        end

        #
        #SCM4
        #

        @medians_scm4 = Median.
            where('start_timestamp >= ?', @date.beginning_of_day.in_time_zone('GMT')).
            where('start_timestamp <= ?', @date.end_of_day.in_time_zone('GMT')).
            where(:schedule_id => Schedule.
                  where(:destination_id => probe.id)).
            where(:threshold_id => 1).
            where("dsavg is not null").
            order('start_timestamp ASC').all


        unless @medians_scm4.empty?
          @report_results[conn_type][probe_type][probe.id][:scm4][:dsavg] =  "Sem Dados"
          @report_results[conn_type][probe_type][probe.id][:scm4][:sdavg] =  "Sem Dados"
          @report_results[conn_type][probe_type][probe.id][:scm4][:color] = ""
          unless  @medians_scm4.first.dsavg.nil? &&  @medians_scm4.first.sdavg.nil?
            if  (((@medians_scm4.first.dsavg.to_f / 1000)/ @medians_scm4.first.schedule.destination.plan.throughput_up.to_f) * 100).round(2) >= 20.0 && (((@medians_scm4.first.sdavg.to_f / 1000)/ @medians_scm4.first.schedule.destination.plan.throughput_down.to_f) * 100).round(2) >= 20.0
                @report_results[conn_type][probe_type][probe.id][:scm4][:color]= "green"
            else
              @report_results[conn_type][probe_type][probe.id][:scm4][:color]= "red"
            end
            @report_results[conn_type][probe_type][probe.id][:scm4][:dsavg] = @medians_scm4.first.pretty_upload(true)
            @report_results[conn_type][probe_type][probe.id][:scm4][:sdavg] =  @medians_scm4.first.pretty_download(true)

          end
        end


        #
        #SCM5
        #

        @medians_scm5 = Median.
            where('start_timestamp >= ?', @date.beginning_of_day.in_time_zone('GMT')).
            where('start_timestamp <= ?', @date.end_of_day.in_time_zone('GMT')).
            where(:schedule_id => Schedule.
                  where(:destination_id => probe.id)).
            where(:threshold_id => 2).
            where("dsavg is not null").
            order('start_timestamp ASC').all

        unless @medians_scm5.empty?
          @report_results[conn_type][probe_type][probe.id][:scm5][:dsavg] =  "Sem Dados"
          @report_results[conn_type][probe_type][probe.id][:scm5][:sdavg] =  "Sem Dados"
          @report_results[conn_type][probe_type][probe.id][:scm5][:color] = ""
          unless  @medians_scm5.first.dsavg.nil? ||  @medians_scm5.first.sdavg.nil?
            up = (@medians_scm5.first.dsavg.to_f / (1000 * @medians_scm5.first.schedule.destination.plan.throughput_up.to_f) * 100).round(2)
            down = (@medians_scm5.first.sdavg.to_f / (1000 * @medians_scm5.first.schedule.destination.plan.throughput_down.to_f) * 100).round(2)
            if up >= 60.0 && down >= 60
              @report_results[conn_type][probe_type][probe.id][:scm5][:color]= "green"
            else
              @report_results[conn_type][probe_type][probe.id][:scm5][:color]= "red"
            end
            @report_results[conn_type][probe_type][probe.id][:scm5][:dsavg] = up.to_s + "%"
            @report_results[conn_type][probe_type][probe.id][:scm5][:sdavg] = down.to_s + "%"

          end
        end
        #
        #SCM6
        #

        @medians_scm6 = Median.
            where('start_timestamp >= ?', @date.beginning_of_day.in_time_zone('GMT')).
            where('start_timestamp <= ?', @date.end_of_day.in_time_zone('GMT')).
            where(:schedule_id => Schedule.
                  where(:destination_id => probe.id)).
            where(:threshold_id => 3).
            where("dsavg is not null").
            order('start_timestamp ASC').all

        unless @medians_scm6.empty?
          @report_results[conn_type][probe_type][probe.id][:scm6][:dsavg] =  "Sem Dados"
          @report_results[conn_type][probe_type][probe.id][:scm6][:color] = ""
          unless  @medians_scm6.first.dsavg.nil?
            if (@medians_scm6.first.dsavg.to_f * 1000).round(2) <= 80.0
              @report_results[conn_type][probe_type][probe.id][:scm6][:color]= "green"
            else
              @report_results[conn_type][probe_type][probe.id][:scm6][:color]= "red"
            end
            @report_results[conn_type][probe_type][probe.id][:scm6][:dsavg] =  @medians_scm6.first.pretty_upload(true)

          end
        end

        #
        #SCM7
        #

        @medians_scm7 = Median.
            where('start_timestamp >= ?', @date.beginning_of_day.in_time_zone('GMT')).
            where('start_timestamp <= ?', @date.end_of_day.in_time_zone('GMT')).
            where(:schedule_id => Schedule.
                  where(:destination_id => probe.id)).
            where(:threshold_id => 4).
            where("dsavg is not null").
            order('start_timestamp ASC').all

        unless @medians_scm7.empty?
          @report_results[conn_type][probe_type][probe.id][:scm7][:dsavg] =  "Sem Dados"
          @report_results[conn_type][probe_type][probe.id][:scm7][:sdavg] =  "Sem Dados"
          @report_results[conn_type][probe_type][probe.id][:scm7][:color] = ""
          unless  @medians_scm7.first.dsavg.nil?  || @medians_scm7.first.sdavg.nil?
            if (@medians_scm7.first.dsavg.to_f * 1000).round(2) <= 80.0 && (@medians_scm7.first.sdavg.to_f * 1000).round(2) <= 80.0
              @report_results[conn_type][probe_type][probe.id][:scm7][:color]= "green"
            else
              @report_results[conn_type][probe_type][probe.id][:scm7][:color]= "red"
            end
            @report_results[conn_type][probe_type][probe.id][:scm7][:dsavg] =  @medians_scm7.first.pretty_upload(true)
            @report_results[conn_type][probe_type][probe.id][:scm7][:sdavg] =  @medians_scm7.first.pretty_download(true)
          end
        end

        #
        #SCM8
        #

        @medians_scm8 = Median.
            where('start_timestamp >= ?', @date.beginning_of_day.in_time_zone('GMT')).
            where('start_timestamp <= ?', @date.end_of_day.in_time_zone('GMT')).
            where(:schedule_id => Schedule.
                  where(:destination_id => probe.id)).
            where(:threshold_id => 5).
            where("dsavg is not null").
            order('start_timestamp ASC').all

        scm8_okay = 0
        scm8_num_total = 0
        scm8_total = 0.0
        @medians_scm8.each do |median|
          unless median.sdavg.nil?
            scm8_okay += 1 if median.sdavg.to_f <= 2.0
            scm8_num_total += median.total_points
            scm8_total += median.sdavg * median.total_points
           end
        end


        unless @medians_scm8.empty?
          @report_results[conn_type][probe_type][probe.id][:scm8][:avg] =  "Sem Dados"
          @report_results[conn_type][probe_type][probe.id][:scm8][:color] = ""
          unless scm8_num_total.zero?
            media = (scm8_total / scm8_num_total.to_f).round(3)
            if media <=  2
              @report_results[conn_type][probe_type][probe.id][:scm8][:color]= "green"
            else
              @report_results[conn_type][probe_type][probe.id][:scm8][:color]= "red"
            end
            @report_results[conn_type][probe_type][probe.id][:scm8][:avg] = media.to_s + "%"
            @report_results[conn_type][probe_type][probe.id][:scm8][:okay] = scm8_okay
            @report_results[conn_type][probe_type][probe.id][:scm8][:total] = scm8_num_total
          end
        end

        #
        #SCM9
        #

        @medians_scm9 = Median.
            where('start_timestamp >= ?', @date.beginning_of_day.in_time_zone('GMT')).
            where('start_timestamp <= ?', @date.end_of_day.in_time_zone('GMT')).
            where(:schedule_id => Schedule.
                  where(:destination_id => probe.id)).
            where(:threshold_id => 6).
            where("dsavg is not null").
            order('start_timestamp ASC').all

        unless @medians_scm9.empty?
          @report_results[conn_type][probe_type][probe.id][:scm9][:dsavg] =  "Sem Dados"
          @report_results[conn_type][probe_type][probe.id][:scm9][:color] = ""
          unless @medians_scm9.first.dsavg.nil?
            media = (@medians_scm9.first.dsavg * 100).round(2)
            if  media >= 99.0
              @report_results[conn_type][probe_type][probe.id][:scm9][:color]= "green"
            else
              @report_results[conn_type][probe_type][probe.id][:scm9][:color]= "red"
            end
            @report_results[conn_type][probe_type][probe.id][:scm9][:dsavg] = media.to_s + "%"
          end
        end

        if (@report_results[conn_type][probe_type][probe.id][:scm4].empty? &&
            @report_results[conn_type][probe_type][probe.id][:scm5].empty? &&
            @report_results[conn_type][probe_type][probe.id][:scm6].empty? &&
            @report_results[conn_type][probe_type][probe.id][:scm7].empty? &&
            @report_results[conn_type][probe_type][probe.id][:scm8].empty? &&
            @report_results[conn_type][probe_type][probe.id][:scm9].empty? )

            @report_results[conn_type][probe_type].delete(probe.id)
        end

    end

    respond_to do |format|
      format.html { render :layout => false }
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
            :upload => (destination.plan[reference_metric+'_up']*1000) * threshold.goal_level,
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
            :upload => threshold.goal_level,
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
        :range => {:start => from, :end => to},
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
        :range => {:start => from, :end => to},
        :results => results
    }

    respond_to do |format|
      format.json { render :json => data, :status => 200 }
    end
  end

  #RELATORIO DE PERFORMANCE
  def performance
    @metrics = params[:metrics]

    respond_to do |format|
      format.html { render :layout => false }
    end

  end



  #########################
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
      format.csv { send_data @end_csv }
    end
  end

  def dygraphs_bruto
    @source = Probe.where(:id => params[:source][:id]).first
    @destination = Probe.where(:id => params[:destination][:id]).first
    @metric = Metric.where(:id => params[:metric][:id]).first
    @schedule = Schedule.where(:destination_id => @destination).where(:source_id => @source).all.last

    @from = DateTime.parse(params[:date][:start]+' '+params[:time][:start]+' '+DateTime.current.zone).in_time_zone
    @to = DateTime.parse(params[:date][:end]+' '+params[:time][:end]+' '+DateTime.current.zone).in_time_zone

    @raw_results = Results.
        where(:schedule_id => @schedule.id).
        where(:metric_id => @metric.id).
        where(:timestamp => @from..@to).order('timestamp ASC').all

    @idName = "dygraph-" << @source.id.to_s << "-" << @destination.id.to_s << "-" << @metric.id.to_s #<< "-" << @from.strftime("%s") << "-" << @to.strftime("%s")
    @exportFileName = @destination.name + '-' + @metric.plugin + '-' + @from.strftime("%Y%m%d_%H%M%S") + '-' +@to.strftime("%Y%m%d_%H%M%S")
    @exportParams = "source=#{@source.id}&destination=#{@destination.id}&metric=#{@metric.id}&from=#{@from.iso8601}&to=#{@to.iso8601}"

    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def highcharts_bruto
      @source = Probe.find(params[:source][:id])
      @destination = Probe.find(params[:destination][:id])
      @metric = Metric.find(params[:metric][:id])
      @schedule = Schedule.where(:destination_id => @destination.id).where(:source_id => @source.id).all.last

      @from = DateTime.parse(params[:date][:start]+' '+params[:time][:start]+' '+DateTime.current.zone).in_time_zone
      @to = DateTime.parse(params[:date][:end]+' '+params[:time][:end]+' '+DateTime.current.zone).in_time_zone

      @choosenSeries = case @metric.plugin
                         when /rtt|loss/
                           {dsavg:"dsdsadsa" }
                         else
                           {sdavg: "Download (Avg)", dsavg:"Upload (Avg)" }
                       end

      @series = Hash.new
      @choosenSeries.each do |key,series|
        @series[key] = {name:series, data:[]}
      end

      @raw_results = Results.
          where(:schedule_id => @schedule.id).
          where(:metric_id => @metric.id).
          where(:timestamp => @from..@to).order('timestamp ASC').all

      @raw_results.each do |res|
        @choosenSeries.each do |key,series|
          @series[key][:data] << [res.timestamp,res[key]]
        end
      end

      @idName = "highcharts-" << @source.id.to_s << "-" << @destination.id.to_s << "-" << @metric.id.to_s #<< "-" << @from.strftime("%s") << "-" << @to.strftime("%s")
      @exportFileName = @destination.name + '-' + @metric.plugin + '-' + @from.strftime("%Y%m%d_%H%M%S") + '-' +@to.strftime("%Y%m%d_%H%M%S")
      @exportParams = "source=#{@source.id}&destination=#{@destination.id}&metric=#{@metric.id}&from=#{@from.iso8601}&to=#{@to.iso8601}"

      respond_to do |format|
        format.html { render :layout => false }
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
      format.csv { send_data @end_csv }
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
      format.csv { send_data @end_csv }
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
      format.html { render :layout => false }
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
      format.html { render :layout => false }
    end
  end

  # Send é chamado pela sonda para enviar reports novos
  def send_report
      report = Nokogiri::XML(params[:report])

      user = report.xpath("report/user").children.to_s
      schedule_uuid = report.xpath("report/uuid").children.to_s
      uuid = report.xpath("report/meas_uuid").children.to_s
      timestamp = report.xpath("report/timestamp").children.to_s
      agent_type = report.xpath("report/agent_type").children.to_s

      #fallback para versoes antigas
      uuid = uuid.empty? ? SecureRandom.uuid : uuid

      case agent_type
      when /windows/i
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

          @kpi = Kpi.create(schedule_uuid: schedule_uuid,
                            uuid: uuid,
                            cell_id: cell_id,
                            model: model,
                            conn_tech: conn_tech,
                            conn_type: conn_type,
                            error_rate: error_rate,
                            lac: lac,
                            mtu: mtu)

          # Results
          rtt = report.xpath("report/results/rtt").children.first.to_s.to_f
          throughput_udp_down = report.xpath("report/results/throughput_udp/down").children.first.to_s.to_f
          throughput_udp_up = report.xpath("report/results/throughput_udp/up").children.first.to_s.to_f
          throughput_tcp_down = report.xpath("report/results/throughput_tcp/down").children.first.to_s.to_f
          throughput_tcp_up = report.xpath("report/results/throughput_tcp/up").children.first.to_s.to_f
          throughput_http_down = report.xpath("report/results/throughput_http/down").children.first.to_s.to_f
          throughput_http_up = report.xpath("report/results/throughput_http/up").children.first.to_s.to_f
          jitter_down = report.xpath("report/results/jitter/down").children.first.to_s.to_f
          jitter_up = report.xpath("report/results/jitter/up").children.first.to_s.to_f
          loss_down = report.xpath("report/results/loss/down").children.first.to_s.to_f
          loss_up = report.xpath("report/results/loss/up").children.first.to_s.to_f
          pom_down = report.xpath("report/results/pom/down").children.first.to_s.to_i
          pom_up = report.xpath("report/results/pom/up").children.first.to_s.to_i
          dns_efic = report.xpath("report/results/dns/efic").children.first.to_s.to_i
          dns_timeout_errors = report.xpath("report/results/dns/errors/timeout").children.first.to_s.to_i
          dns_server_failure_errors = report.xpath("report/results/dns/errors/server_failure").children.first.to_s.to_i

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
                                                 schedule_uuid: schedule_uuid,
                                                 dns_efic: dns_efic,
                                                 dns_timeout_errors: dns_timeout_errors,
                                                 dns_server_failure_errors: dns_server_failure_errors,
                                                 user: user)

          # DNS test results
          dns_server = dns_url = dns_delay = nil
          @dns_dynamic_results = []
          report.xpath("report/results/dns/test").each do |c|
              dns_server = c.children.search("server").inner_text
              dns_url = c.children.search("url").inner_text
              dns_delay = c.children.search("delay").inner_text.to_f
              dns_status = c.children.search("status").inner_text.to_f

              @dns_dynamic_results << DnsDynamicResult.create(server: dns_server,
                                                              url: dns_url,
                                                              delay: dns_delay,
                                                              status: dns_status,
                                                              schedule_uuid: schedule_uuid,
                                                              uuid: uuid)
          end

          # Web Load test results
          web_load_url = web_load_time = web_load_size = web_load_throughput = nil
          @web_load_dynamic_results = []
          report.xpath("report/results/web_load/test").each do |c|
              web_load_url = c.children.search("url").inner_text
              web_load_time = c.children.search("time").inner_text.to_f
              web_load_size = c.children.search("size").inner_text.to_f
              web_load_throughput = c.children.search("trhoughput").inner_text.to_f

              @web_load_dynamic_results << WebLoadDynamicResult.create(url: web_load_url,
                                                                       time: web_load_time,
                                                                       size: web_load_size,
                                                                       throughput: web_load_throughput,
                                                                       schedule_uuid: schedule_uuid,
                                                                       uuid: uuid)
          end

      when /linux|android/i
          @rep = Report.create(user: user, uuid: uuid, timestamp: DateTime.strptime(timestamp, '%s'), agent_type: agent_type)

          results = report.xpath("report/results").children

          @probe = Probe.where(ipaddress: user).first

          # Update agent version
          @probe.update_attributes(agent_version: report.xpath("report/version").inner_text)

          results.each do |result|
              case result.name
              when "availability"
                  total = result.xpath("total").children.text.to_i
                  success = result.xpath("success").children.text.to_i

                  @schedule = @probe.schedules.last

                  @metric = Metric.find_by_plugin("availability")

                  @threshold = Threshold.find_by_goal_method("availability")

                  @median = Median.new(schedule_uuid: @schedule.uuid,
                                       start_timestamp: (DateTime.strptime(timestamp, '%s') - 23.hours - 59.minutes - 59.seconds),
                                       end_timestamp: DateTime.strptime(timestamp, '%s'),
                                       expected_points: total,
                                       total_points: success,
                                       dsavg: success.to_f/total.to_f)
                  @median.schedule = @schedule
                  @median.threshold = @threshold

                  @median.save
              when "web_load"
                  url = time = size = throughput = time_main_domain = size_main_domain = throughput_main_domain = time_other_domain = size_other_domain = throughput_other_domain = nil
                  @web_load_results = []
                  report.xpath("report/results/web_load/test").each do |c|
                      url = c.children.search("url") .inner_text
                      time = c.children.search("time").inner_text.to_f
                      size = c.children.search("size").inner_text.to_i
                      throughput = c.children.search("throughput").inner_text.to_f
                      time_main_domain = c.children.search("time_main_domain").inner_text.to_f
                      size_main_domain = c.children.search("size_main_domain").inner_text.to_i
                      throughput_main_domain = c.children.search("throughput_main_domain").inner_text.to_f
                      time_other_domain = c.children.search("time_main_domain").inner_text.to_f
                      size_other_domain = c.children.search("size_other_domain").inner_text.to_i
                      throughput_other_domain = c.children.search("throughput_other_domain").inner_text.to_f
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
                                                                schedule_uuid: schedule_uuid,
                                                                uuid: uuid)
                  end
              when "dns"
                  server = url = delay = nil
                  efic = average = timeout_errors = server_failure_errors = nil
                  @dns_results = []
                  report.xpath("report/results/dns/test").each do |c|
                      server = c.children.search("server").inner_text
                      url = c.children.search("url").inner_text
                      delay = c.children.search("delay").inner_text.to_i
                      dns_status = c.children.search("status").inner_text.to_f
                      @dns_results << DnsResult.create(url: url,
                                                       server: server,
                                                       delay: delay,
                                                       status: dns_status,
                                                       schedule_uuid: schedule_uuid,
                                                       uuid: uuid)
                  end
                  efic = report.xpath("report/results/dns/efic").inner_text.to_f
                  average = report.xpath("report/results/dns/media").inner_text.to_f
                  timeout_errors = report.xpath("report/results/dns/errors/timeout")
                  server_failure_errors = report.xpath("report/results/dns/errors/server_failures")
                  @dns_detail = DnsDetail.create(efic: efic,
                                                 average: average,
                                                 timeout_errors: timeout_errors,
                                                 server_failure_errors: server_failure_errors,
                                                 schedule_uuid: schedule_uuid,
                                                 uuid: uuid)
              when "throughput_http"
                  throughput_http_down = report.xpath("report/results/throughput_http/down").to_s.to_f
                  throughput_http_up = report.xpath("report/results/throughput_http/up").to_s.to_f

                  metric = Metric.where(plugin: "throughput_http")
                  probe = Probe.where(ipaddress: user).first
                  schedule = probe.schedules_as_destination.last

                  @results = Results.create(schedule_id: schedule.id,
                                            metric_id: metric,
                                            schedule_uuid: schedule_uuid,
                                            uuid: uuid,
                                            metric_name: "throughput_http",
                                            timestamp: timestamp,
                                            sdavg: throughput_http_down,
                                            dsavg: throughput_http_up)
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
