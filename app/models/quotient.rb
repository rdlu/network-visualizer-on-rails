# coding: utf-8
class Quotient < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :threshold
  attr_accessible :download, :end_timestamp, :expected_days, :schedule_uuid, :start_timestamp, :total_days, :upload, :type

  @inheritance_column = 'type2'

  def self.calculate (schedule, threshold, reference_date)
    case threshold.goal_method
      when 'median'
        #periodo de calculo
        start_period = reference_date.at_beginning_of_month
        end_period = reference_date

        #agora consulta os valores do periodo e calcula o quociente
        medians = Median.where('start_timestamp >= ?', start_period).where('end_timestamp <= ?', end_period).where(:schedule_id => schedule.id).where(:threshold_id => threshold.id).all

        quotient = Quotient.
            where(:schedule_id => schedule.id).
            where(:threshold_id => threshold.id).
            where(:start_timestamp => start_period).first
        quotient = Quotient.new if quotient.nil?
        if medians.length > 0
          download_sum = 0.to_f
          upload_sum = 0.to_f
          medians.each do |median|
            download_sum += median.dsavg
            upload_sum += median.sdavg
          end
          quotient.download = download_sum / medians.length
          quotient.upload = upload_sum / medians.length

        end
        #outros dados
        quotient.schedule = schedule
        quotient.threshold = threshold
        quotient.total_days = medians.length
        quotient.expected_days = (end_period.to_date - start_period.to_date).to_i + 1
        quotient.start_timestamp=start_period.to_datetime.in_time_zone('GMT')
        quotient.end_timestamp=end_period.to_datetime.in_time_zone('GMT')
        quotient.type = threshold.goal_period

        quotient.save!
      else
        Yell.new(:gelf, :facility => 'netmetric').send 'warn', "Tentativa de calculo de quocientes com método não suportado: #{threshold.goal_method}",
                                                        '_schedule_id' => schedule.id, '_probe_id' => schedule.source.id, '_threshold_id' => threshold.id
    end
  end
end
