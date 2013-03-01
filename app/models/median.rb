# coding: utf-8
class Median < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :threshold
  attr_accessible :end_timestamp, :expected_points, :schedule_uuid, :start_timestamp, :total_points, :dsavg, :sdavg, :type

  #quero o 'type' para meus propositos
  @inheritance_column = 'type2'

  def self.calculate (schedule, threshold, reference_date)
    if threshold.goal_method == 'median'
      start_period = reference_date
      end_period = reference_date
      case threshold.goal_period
        when 'daily-rush'
          start_period = reference_date.beginning_of_day + 8.hours
          end_period = reference_date.beginning_of_day + 22.hours
        when 'daily'
          start_period = reference_date.beginning_of_day
          end_period = reference_date.end_of_day
        else
          Yell.new(:gelf, :facility => 'netmetric').alert "Tentativa de calculo de medianas em utilizando período não suportado: #{threshold.goal_period}",
                                                          '_schedule_id' => schedule.id, '_probe_id' => schedule.source.id, '_threshold_id' => threshold.id
      end
      #agora consulta os valores do periodo e calcula a mediana
      results = Results.where(:timestamp => start_period..end_period).where(:schedule_id => schedule.id).where(:metric_id => threshold.metric.id).all
      len = results.length

      if len > 0
        median = Median.
            where(:schedule_id => schedule.id).
            where(:threshold_id => threshold.id).
            where(:start_timestamp => start_period).
            where(:end_timestamp => end_period).first
        median = Median.new if median.nil?
        #mediana do download
        results_ordered_by_dsavg = results.sort_by {|hsh| hsh[:dsavg]}
        median.dsavg = len % 2 == 1 ? results_ordered_by_dsavg[len/2].dsavg : (results_ordered_by_dsavg[len/2 - 1].dsavg + results_ordered_by_dsavg[len/2].dsavg).to_f / 2

        #mediana do upload
        results_ordered_by_sdavg = results.sort_by {|hsh| hsh[:sdavg]}
        median.sdavg = len % 2 == 1 ? results_ordered_by_sdavg[len/2].sdavg : (results_ordered_by_sdavg[len/2 - 1].sdavg + results_ordered_by_sdavg[len/2].sdavg).to_f / 2

        #outros dados da mediana
        median.schedule = schedule
        median.threshold = threshold
        median.total_points = len
        median.expected_points = ((end_period - start_period)/60) / schedule.polling
        median.start_timestamp=start_period
        median.end_timestamp=end_period
        median.type = threshold.goal_period

        median.save!
      end

    else
      Yell.new(:gelf, :facility => 'netmetric').alert "Tentativa de calculo de medianas em um limiar que não é do tipo mediana: #{threshold.name}",
                                                     '_schedule_id' => schedule.id, '_probe_id' => schedule.source.id, '_threshold_id' => threshold.id
    end
  end
end
