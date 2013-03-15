# coding: utf-8
class Median < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :threshold
  attr_accessible :end_timestamp, :expected_points, :schedule_uuid, :start_timestamp, :total_points, :dsavg, :sdavg, :type

  #quero o 'type' para meus propositos
  @inheritance_column = 'type2'

  def download
    self.sdavg
  end

  def upload
    self.dsavg
  end

  def view_unit
    self.threshold.metric.view_unit
  end

  def db_unit
    self.threshold.metric.db_unit
  end

  def raw_view_unit
    self.threshold.metric.raw_view_unit
  end

  def raw_db_unit
    self.threshold.metric.raw_db_unit
  end

  def metric
    self.threshold.metric
  end

  def download_with_unit
    "#{self.download} #{self.metric.raw_db_unit}".to_unit
  end

  def pretty_download(auto_choose_unit = false)
    begin
      if auto_choose_unit
        if (self.download_with_view_unit =~ '1 Mb/s'.to_unit) && (self.download_with_view_unit > '1 Mb/s'.to_unit)
          return self.download_with_view_unit.convert_to('Mb/s').to_s('%0.2f').gsub(/b\/s|B\/s/,'b/s' => 'bps', 'B/s' => 'Bps')
        end
      end
      return self.download_with_view_unit.to_s('%0.2f').gsub(/b\/s|B\/s/,'b/s' => 'bps', 'B/s' => 'Bps')
    rescue Exception => e
      return 'Sem dados'
    end
  end

  def upload_with_unit
    "#{self.upload} #{self.metric.raw_db_unit}".to_unit
  end

  def pretty_upload(auto_choose_unit = false)
    begin
      if auto_choose_unit
        if (self.upload_with_view_unit =~ '1 Mb/s'.to_unit) && (self.upload_with_view_unit > '1 Mb/s'.to_unit)
          return self.upload_with_view_unit.convert_to('Mb/s').to_s('%0.2f').gsub(/b\/s|B\/s/,'b/s' => 'bps', 'B/s' => 'Bps')
        end
      end
      self.upload_with_view_unit.to_s('%0.2f').gsub(/b\/s|B\/s/,'b/s' => 'bps', 'B/s' => 'Bps')
    rescue Exception => e
      return 'Sem dados'
    end
  end

  #pode ser formatado com .to_s("%0.3f"), ou seja fixed com 3 casas depois da virgula
  def download_with_view_unit
    "#{self.download} #{self.metric.raw_db_unit}".to_unit(self.metric.raw_view_unit)
  end

  def upload_with_view_unit
    "#{self.upload} #{self.metric.raw_db_unit}".to_unit(self.metric.raw_view_unit)
  end

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
          Yell.new(:gelf, :facility => 'netmetric').warning "Tentativa de calculo de medianas em utilizando período não suportado: #{threshold.goal_period}",
                                                          '_schedule_id' => schedule.id, '_probe_id' => schedule.source.id, '_threshold_id' => threshold.id
      end
      #agora consulta os valores do periodo e calcula a mediana
      results = Results.where(:timestamp => start_period..end_period).where(:schedule_id => schedule.id).where(:metric_id => threshold.metric.id).all
      len = results.length

        median = Median.
            where(:schedule_id => schedule.id).
            where(:threshold_id => threshold.id).
            where(:start_timestamp => start_period).
            where(:end_timestamp => end_period).first
        median = Median.new if median.nil?
      if len > 0
        #mediana do download
        results_ordered_by_dsavg = results.sort_by {|hsh| hsh[:dsavg]}
        median.dsavg = len % 2 == 1 ? results_ordered_by_dsavg[len/2].dsavg : (results_ordered_by_dsavg[len/2 - 1].dsavg + results_ordered_by_dsavg[len/2].dsavg).to_f / 2

        #mediana do upload
        results_ordered_by_sdavg = results.sort_by {|hsh| hsh[:sdavg]}
        median.sdavg = len % 2 == 1 ? results_ordered_by_sdavg[len/2].sdavg : (results_ordered_by_sdavg[len/2 - 1].sdavg + results_ordered_by_sdavg[len/2].sdavg).to_f / 2
      end
        #outros dados da mediana
        median.schedule = schedule
        median.threshold = threshold
        median.total_points = len
        end_time = end_period.to_time.to_i
        start_time = start_period.to_time.to_i
        diff_time = end_time - start_time
        median.expected_points = (diff_time/60) / schedule.polling
        median.start_timestamp=start_period
        median.end_timestamp=end_period
        median.type = threshold.goal_period

        median.save!
    else
      Yell.new(:gelf, :facility => 'netmetric').send 'warn', "Tentativa de calculo de medianas em um limiar que não é do tipo mediana: #{threshold.name}",
                                                     '_schedule_id' => schedule.id, '_probe_id' => schedule.source.id, '_threshold_id' => threshold.id
    end
  end
end
