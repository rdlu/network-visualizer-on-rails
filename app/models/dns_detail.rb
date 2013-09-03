# == Schema Information
#
# Table name: dns_details
#
#  id                    :integer          not null, primary key
#  efic                  :float
#  average               :float
#  timeout_errors        :integer
#  server_failure_errors :integer
#  uuid                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class DnsDetail < ActiveRecord::Base
  attr_accessible :average, :efic, :server_failure_errors, :timeout_errors, :uuid, :schedule_uuid, :total

  def timeout
    unless total.nil?
      timeout_errors.to_f/total.to_f
    else
      nil
    end
  end

  def server_failures
    unless total.nil?
      server_failure_errors.to_f/total.to_f
    else
      nil
    end
  end

end
