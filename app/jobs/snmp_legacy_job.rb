# coding: utf-8
class SnmpLegacyJob
  def self.profile_setup(profile, schedule)
    config_hash = JSON.load(profile.config_parameters)
    base_index = config_hash['profile']['base']
    data_array = config_hash['profile']['data']

    require 'resolv'
    begin
      real_ipaddress = schedule.source.real_ipaddress
      response = []
      SNMP::Manager.open(:host => real_ipaddress) do |manager|
      #SNMP::Manager.open(:host => '143.54.85.34') do |manager|
        snmp_response = manager.get([base_index+data_array.at(0).to_a.at(0).at(0)])
        snmp_response.each_varbind do |vb|
          response << {:name => vb.name.to_s, :value => vb.value.to_s, :type => vb.value.asn1_type}
        end
      end

      if response.at(0)[:value] == 'notSet'
        manager = SNMP::Manager.new(:host => real_ipaddress, :community => 'suppublic')
        data_array.each do |data|
          key = data.to_a.at(0).at(0)
          value = data.to_a.at(0).at(1)
          if value.is_a? Integer
            manager.set(SNMP::VarBind.new(base_index+key, SNMP::Integer.new(value)))
          else
            manager.set(SNMP::VarBind.new(base_index+key, SNMP::OctetString.new(value)))
          end
        end
        manager.close
        Yell.new(:gelf, :facility=>'netmetric').info "Perfil #{profile.name} enviado para a sonda #{schedule.source.name}",
                                                     '_schedule_id' => schedule.id
      else
        Yell.new(:gelf, :facility=>'netmetric').info "Perfil #{profile.name} já existente na sonda #{schedule.source.name}",
                                                      '_schedule_id' => schedule.id
      end
    rescue Resolv::ResolvError => error
      Yell.new(:gelf, :facility=>'netmetric').error 'Nao foi possivel enviar os valores: '+error.to_s,
                                                    '_schedule_id' => schedule.id,
                                                    '_error' => error
      raise DelayedJob::Exception, 'Erro na execução do job snmp_legacy'
    rescue Exception => error
      Yell.new(:gelf, :facility=>'netmetric').fatal 'Nao foi possivel enviar os valores: '+error.to_s,
                                                    '_schedule_id' => schedule.id,
                                                    '_error_complete' => error
    end
  end
end