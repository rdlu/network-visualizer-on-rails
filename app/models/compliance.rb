# coding: utf-8
class Compliance < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :threshold
  attr_accessible :download, :end_timestamp, :expected_days, :schedule_uuid, :start_timestamp, :total_days, :upload, :type, :calc_method

  @inheritance_column = 'type2'

  def self.calculate (schedule, threshold, reference_date)
    case threshold.goal_method
      when 'median'
        #periodo de calculo
        start_period = reference_date.at_beginning_of_month
        end_period = reference_date

        #agora consulta os valores do periodo e calcula o quociente
        medians = Median.
            where('start_timestamp >= ?', start_period).
            where('end_timestamp <= ?', end_period).
            where(:schedule_id => schedule.id).
            where(:threshold_id => threshold.id).where('dsavg IS NOT NULL').
            all

        compliance = Compliance.
            where(:schedule_id => schedule.id).
            where(:threshold_id => threshold.id).
            where(:start_timestamp => start_period).first
        compliance = Compliance.new if compliance.nil?

        if medians.length > 0
          reference_metric = threshold.metric.plugin.split('_').at(0)

          reference_download_value = 0
          reference_upload_value = 0
          if reference_metric == 'throughput'
            reference_download_value = (schedule.destination.plan[reference_metric+'_down'].to_unit('kb/s')) * threshold.goal_level
            reference_upload_value = (schedule.destination.plan[reference_metric+'_up'].to_unit('kb/s')) * threshold.goal_level
          else
            reference_download_value = threshold.goal_level.to_unit(medians.first.raw_view_unit)
            reference_upload_value =  threshold.goal_level.to_unit(medians.first.raw_view_unit)
          end

          case threshold.compliance_method
            when 'mean'
              download_sum = 0.to_f
              upload_sum = 0.to_f
              scalar_reference_down = schedule.destination.plan[reference_metric+'_down'].to_unit('kb/s').scalar
              scalar_reference_up = schedule.destination.plan[reference_metric+'_up'].to_unit('kb/s').scalar
              medians.each do |median|
                scalar_download = median.download_with_unit.convert_to('kb/s').scalar.to_f
                download_sum += scalar_download / scalar_reference_down
                upload_sum += median.upload_with_unit.convert_to('kb/s').scalar / scalar_reference_up
              end
              #TODO: confirmar numero total de medicoes (exclui valores nulos?)
              compliance.download = download_sum / medians.length
              compliance.upload = upload_sum / medians.length
            when 'quotient'
              download_sum = 0
              upload_sum = 0
              medians.each do |median|
                if reference_metric == 'throughput'
                  download_sum += 1 if median.download_with_unit >= reference_download_value
                  upload_sum += 1 if median.upload_with_unit >= reference_upload_value
                else
                  download_sum += 1 if median.download_with_unit + median.upload_with_unit <= reference_download_value
                end
              end
              #TODO: confirmar numero total de medicoes (exclui valores nulos?)
              compliance.download = download_sum.to_f / medians.length.to_f
              compliance.upload = upload_sum.to_f / medians.length.to_f
            else
              Yell.new(:gelf, :facility => 'netmetric').send 'warn', "Tentativa de calculo de quocientes com método de cumprimento não suportado: #{threshold.compliance_method}",
                                                             '_schedule_id' => schedule.id, '_probe_id' => schedule.source.id, '_threshold_id' => threshold.id
          end
        end

        #outros dados
        compliance.schedule = schedule
        compliance.threshold = threshold
        compliance.total_days = medians.length
        compliance.expected_days = (end_period.to_date - start_period.to_date).to_i
        compliance.start_timestamp=start_period.to_datetime.in_time_zone('GMT')
        compliance.end_timestamp=end_period.to_datetime.in_time_zone('GMT')
        compliance.type = threshold.goal_period
        compliance.calc_method = threshold.compliance_method
        compliance.save!
      else
        Yell.new(:gelf, :facility => 'netmetric').send 'warn', "Tentativa de calculo de quocientes com método de meta não suportado: #{threshold.goal_method}",
                                                        '_schedule_id' => schedule.id, '_probe_id' => schedule.source.id, '_threshold_id' => threshold.id
    end
  end
end
