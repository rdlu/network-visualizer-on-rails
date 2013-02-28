# coding: utf-8
class SnmpLegacyJobException < Exception

end

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
        snmp_response = manager.get([base_index+data_array.at(0).to_a.at(0).at(0)+profile.id.to_s])
        snmp_response.each_varbind do |vb|
          response << {:name => vb.name.to_s, :value => vb.value.to_s, :type => vb.value.asn1_type}
        end
      end

      if response.at(0)[:value] == 'notSet'
        manager = SNMP::Manager.new(:host => real_ipaddress, :community => 'suppublic')
        data_array.each do |data|
          key = data.to_a.at(0).at(0) + profile.id.to_s
          value = data.to_a.at(0).at(1)
          if value.is_a? Integer
            manager.set(SNMP::VarBind.new(base_index+key, SNMP::Integer.new(value)))
          else
            manager.set(SNMP::VarBind.new(base_index+key, SNMP::OctetString.new(value)))
          end
        end
        manager.close
        Yell.new(:gelf, :facility => 'netmetric').info "Perfil #{profile.name} enviado para a sonda #{schedule.source.name}",
                                                       '_schedule_id' => schedule.id, '_probe_id' => schedule.source.id
      else
        Yell.new(:gelf, :facility => 'netmetric').info "Perfil #{profile.name} ja existente na sonda #{schedule.source.name}",
                                                       '_schedule_id' => schedule.id, '_probe_id' => schedule.source.id
      end
    rescue Resolv::ResolvError => error
      Yell.new(:gelf, :facility => 'netmetric').error 'Nao foi possivel enviar os valores: '+error.to_s,
                                                      '_schedule_id' => schedule.id, '_probe_id' => schedule.source.id,
                                                      '_error' => error
      raise SnmpLegacyJobException, 'Erro na execução do job snmp_legacy'
    rescue Exception => error
      Yell.new(:gelf, :facility => 'netmetric').fatal 'Nao foi possivel enviar os valores: '+error.to_s,
                                                      '_schedule_id' => schedule.id, '_probe_id' => schedule.source.id,
                                                      '_error_complete' => error
      raise SnmpLegacyJobException 'Fatal error on snmp scheduling process'
    end
  end

  def self.manager_setup(profiles, schedule)

    real_ipaddress = schedule.source.real_ipaddress

    ports = ''
    profile_ids = ''
    profiles.each do |profile|
      ports << '1200'+profile.id.to_s + ' '
      profile_ids << profile.id.to_s + ' '
    end
    ports = '12001 12002 12003'
    ports = ports.strip
    profile_ids = profile_ids.strip
    table_id = schedule.destination.id.to_s
    hostname = schedule.destination.ipaddress
    hostname = hostname + '.vivo.com.br' if (hostname.match('^(?!.*\.vivo.com.br$)[\/\w\.-]+$') && (schedule.destination.hostname? hostname))

    status = schedule.destination.type == 'android' ? 0 : 1

    data_array = [
        ['.0.9.'+table_id, 6],
        ['.0.0.'+table_id, hostname],
        ['.0.1.'+table_id, ports],
        ['.0.4.'+table_id, schedule.destination.name],
        ['.0.5.'+table_id, schedule.destination.city],
        ['.0.6.'+table_id, schedule.destination.state],
        #['.0.7.'+table_id, 1],
        ['.0.8.'+table_id, profile_ids],
        ['.0.10.'+table_id, status],
        ['.0.15.'+table_id,schedule.polling*60],
        ['.0.16.'+table_id,schedule.polling*60],
        ['.0.18.'+table_id, status^1],
        ['.0.9.'+table_id, 2],
    ]

    base_index = '1.3.6.1.4.1.12000.0'

    begin
      manager = SNMP::Manager.new(:host => real_ipaddress, :community => 'suppublic')
      data_array.each do |key, value|
        if value.is_a? Integer
          manager.set(SNMP::VarBind.new(base_index+key, SNMP::Integer.new(value)))
        else
          manager.set(SNMP::VarBind.new(base_index+key, SNMP::OctetString.new(value)))
        end
      end
      manager.close
      Yell.new(:gelf, :facility => 'netmetric').info "Gerente #{schedule.source.name} liberado para enviar rajadas ao Agente #{schedule.destination.name}",
                                                     '_schedule_id' => schedule.id, '_probe_id' => schedule.source.id
    rescue Exception => error
      Yell.new(:gelf, :facility => 'netmetric').error 'Nao foi possivel enviar o managerTable: '+error.to_s,
                                                      '_schedule_id' => schedule.id, '_probe_id' => schedule.source.id,
                                                      '_error' => error
      raise SnmpLegacyJobException, 'Erro na execução do job snmp_legacy ao configurar o gerente'
    end
  end

  #seta a managerTable
  def self.agent_setup(profiles, schedule)
    Yell.new(:gelf, :facility => 'netmetric').info 'Agentes de versao recente não necessitam configuração via SNMP.',
                                                   '_schedule_id' => schedule.id, '_probe_id' => schedule.destination.id
    return nil
  end
end