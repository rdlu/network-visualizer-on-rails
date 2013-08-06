# coding: utf-8
# == Schema Information
#
# Table name: compliances
#
#  id              :integer          not null, primary key
#  schedule_id     :integer
#  threshold_id    :integer
#  schedule_uuid   :string(255)
#  start_timestamp :timestamp(6)
#  end_timestamp   :timestamp(6)
#  expected_days   :integer
#  total_days      :integer
#  download        :float
#  upload          :float
#  created_at      :timestamp(6)     not null
#  updated_at      :timestamp(6)     not null
#  type            :string(255)
#  calc_method     :string(255)
#

class Compliance < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :threshold
  attr_accessible :download, :end_timestamp, :expected_days, :schedule_uuid, :start_timestamp, :total_days, :upload, :type, :calc_method

  @inheritance_column = 'type2'

  def self.calculate (schedule, threshold, reference_date)
    #periodo de calculo
    start_period = reference_date.to_time.at_beginning_of_month
    end_period = reference_date.to_time

    #agora consulta os valores do periodo e calcula o quociente
    medians = Median.
        where('start_timestamp >= ?', start_period).
        where('end_timestamp <= ?', end_period + 1.day).
        where(:schedule_id => schedule.id).
        where(:threshold_id => threshold.id).where('dsavg IS NOT NULL').
        all

    compliance = Compliance.
        where(:schedule_id => schedule.id).
        where(:threshold_id => threshold.id).
        where(:start_timestamp => start_period).first
    compliance = Compliance.new if compliance.nil?

    case threshold.goal_method
      when 'median'
        if medians.length > 0
          reference_metric = threshold.metric.plugin.split('_').at(0)

          reference_download_value = 0
          reference_upload_value = 0
          if reference_metric == 'throughput'
            reference_download_value = (schedule.destination.plan[reference_metric+'_down'].to_unit('kb/s')) * threshold.goal_level
            reference_upload_value = (schedule.destination.plan[reference_metric+'_up'].to_unit('kb/s')) * threshold.goal_level
          else
            reference_download_value = threshold.goal_level.to_unit(medians.first.raw_view_unit)
            reference_upload_value = threshold.goal_level.to_unit(medians.first.raw_view_unit)
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
              combined_sum = 0
              medians.each do |median|
                case reference_metric
                  when 'throughput'
                    download_sum += 1 if median.download_with_unit >= reference_download_value
                    upload_sum += 1 if median.upload_with_unit >= reference_upload_value
                    combined_sum += 1 if median.upload_with_unit >= reference_upload_value && median.download_with_unit >= reference_download_value
                  when 'jitter'
                    combined_sum += 1 if median.upload_with_unit <= reference_upload_value && median.download_with_unit <= reference_download_value
                  else
                    download_sum += 1 if median.download_with_unit + median.upload_with_unit <= reference_download_value
                    combined_sum = download_sum
                end
              end
              #TODO: confirmar numero total de medicoes (exclui valores nulos?)
              compliance.download = combined_sum.to_f / medians.length.to_f
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
      when "availability"
        # SCM9 - sum(total)/sum(expected)
        # resultado -> compliance.download
        if medians.length > 0
          total = 0
          expected = 0
          medians.each do |median|
            total += median.total_points
            expected += median.expected_points
          end

          if expected != 0
            compliance.download = total.to_f / expected.to_f
          else
            compliance.download = 0
          end
        else
          # Não temos dados, mas download não pode ficar nulo
          compliance.download = 0
        end

        compliance.schedule = schedule
        compliance.threshold = threshold
        compliance.total_days = medians.length
        compliance.expected_days = (end_period.to_date - start_period.to_date).to_i
        compliance.start_timestamp=start_period.to_datetime.in_time_zone('GMT')
        compliance.end_timestamp=end_period.to_datetime.in_time_zone('GMT')
        compliance.type = threshold.goal_period
        compliance.calc_method = threshold.compliance_method
        compliance.save!
      when 'raw'
        #scm 8 como exemplo
#       results = Results.where(:timestamp => start_period..end_period).where(:schedule_id => schedule.id).where(:metric_id => threshold.metric.id).all
#       len = results.length.to_i
	len = medians.length.to_i

        raw_sum_ds = 0
        raw_sum_sd = 0
#       results.each do |result|
	medians.each do |median|
#       if result.dsavg / 100 <= threshold.goal_level
	  if median.dsavg <= threshold.goal_level
            raw_sum_ds += 1
          end

#         if result.sdavg / 100 <= threshold.goal_level
	  if median.sdavg <= threshold.goal_level
            raw_sum_sd += 1
          end
        end

        compliance.download = len == 0 ? 0 : (raw_sum_sd / len.to_f)
        compliance.upload = len == 0 ? 0 : (raw_sum_ds / len.to_f)
        compliance.schedule = schedule
        compliance.threshold = threshold
        compliance.total_days = medians.length
        compliance.expected_days = (end_period.to_date - start_period.to_date).to_i
        compliance.start_timestamp = start_period.to_datetime.in_time_zone('GMT')
        compliance.end_timestamp = end_period.to_datetime.in_time_zone('GMT')
        compliance.type = threshold.goal_period
        compliance.calc_method = threshold.compliance_method
        compliance.save!
      else
        Yell.new(:gelf, :facility => 'netmetric').send 'warn', "Tentativa de calculo de quocientes com método de meta não suportado: #{threshold.goal_method}",
                                                       '_schedule_id' => schedule.id, '_probe_id' => schedule.source.id, '_threshold_id' => threshold.id
    end
  end
end
