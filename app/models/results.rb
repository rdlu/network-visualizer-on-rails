class Results < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :metric
  attr_accessible :dsavg, :dsmax, :dsmin, :schedule_uuid, :sdavg, :sdmax, :sdmin, :timestamp, :uuid, :metric_name, :schedule_id, :metric_id

  def timestamp= value
    if value.is_a? Date
      self[:timestamp] = value.to_datetime
    else
      #converte do formato UNIX TIMESTAMP
      self[:timestamp] = DateTime.strptime(value, '%s')
    end
  end

  def view_unit
    self.metric.view_unit
  end

  def db_unit
    self.metric.db_unit
  end

  def download
    self.sdavg
  end

  def upload
    self.dsavg
  end

  def download_with_unit
     "#{self.download} #{self.metric.raw_db_unit}".to_unit
  end

  def pretty_download(auto_choose_unit = false)
    if auto_choose_unit
      if (self.download_with_view_unit =~ '1 Mb/s'.to_unit) && (self.download_with_view_unit > '1 Mb/s'.to_unit)
        return self.download_with_view_unit.convert_to('Mb/s')
      end
    end
    self.download_with_view_unit.to_s('%0.2f')
  end

  def upload_with_unit
    "#{self.upload} #{self.metric.raw_db_unit}".to_unit
  end

  def pretty_upload(auto_choose_unit = false)
    if auto_choose_unit
      if (self.upload_with_view_unit =~ '1 Mb/s'.to_unit) && (self.upload_with_view_unit < '1 Mb/s'.to_unit)
        return self.upload_with_view_unit.convert_to('Mb/s')
      end
    end
    self.upload_with_view_unit.to_s('%0.2f')
  end

  #pode ser formatado com .to_s("%0.3f"), ou seja fixed com 3 casas depois da virgula
  def download_with_view_unit
    "#{self.download} #{self.metric.raw_db_unit}".to_unit(self.metric.raw_view_unit)
  end

  def upload_with_view_unit
    "#{self.upload} #{self.metric.raw_db_unit}".to_unit(self.metric.raw_view_unit)
  end

  def pretty_scalar_download
    "#{self.download} #{self.metric.raw_db_unit}".to_unit(self.metric.raw_view_unit).scalar
  end

  def pretty_scalar_upload
    "#{self.upload} #{self.metric.raw_db_unit}".to_unit(self.metric.raw_view_unit).scalar
  end
end
