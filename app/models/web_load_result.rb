class WebLoadResult < ActiveRecord::Base
  attr_accessible :size, :size_main_domain, :size_other_domain, :throughput, :throughput_main_domain, :throughput_other_domain, :time, :time_main_domain, :time_other_domain, :url, :uuid
end
