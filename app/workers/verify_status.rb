# coding: utf-8

class VerifyStatus
  def self.perform
    Yell.new(:gelf, :facility => 'netmetric-jobs').info "Performing probe status verification"
    Probe.all.each do |probe|
      probe.touch
      unless probe.schedules.empty?
        if probe.updated_at < Time.now - (probe.schedules.first.polling*2).minutes
          probe.status = 2
        end

        if probe.updated_at < Time.now - (probe.schedules.first.polling*3).minutes
          probe.status = 3
        end

        probe.record_timestamps=false
        probe.save
        probe.record_timestamps=true
      end
    end
  end
end