class WebLoadDynamicTestResult < ActiveRecord::Base
  attr_accessible :size, :throughput, :time, :url, :uuid
end
