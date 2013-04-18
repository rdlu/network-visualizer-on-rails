class WebLoadDynamicResult < ActiveRecord::Base
  attr_accessible :size, :throughput, :time, :url, :uuid
end
