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
        Yell.new(:gelf, :facility => 'netmetric').info "Perfil #{profile.name} enviado para a sonda #{schedule.source.name}",
                                                       '_schedule_id' => schedule.id
      else
        Yell.new(:gelf, :facility => 'netmetric').info "Perfil #{profile.name} já existente na sonda #{schedule.source.name}",
                                                       '_schedule_id' => schedule.id
      end
    rescue Resolv::ResolvError => error
      Yell.new(:gelf, :facility => 'netmetric').error 'Nao foi possivel enviar os valores: '+error.to_s,
                                                      '_schedule_id' => schedule.id,
                                                      '_error' => error
      raise SnmpLegacyJobException, 'Erro na execução do job snmp_legacy'
    rescue Exception => error
      Yell.new(:gelf, :facility => 'netmetric').fatal 'Nao foi possivel enviar os valores: '+error.to_s,
                                                      '_schedule_id' => schedule.id,
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
    ports = ports.strip
    profile_ids = profile_ids.strip
    table_id = schedule.destination.id.to_s

    data_array = [
        ['.0.9'+table_id, 6],
        ['.0.0'+table_id, schedule.destination.real_ipaddress],
        ['.0.1'+table_id, ports],
        ['.0.4'+table_id, schedule.destination.name],
        ['.0.5'+table_id, schedule.destination.city],
        ['.0.6'+table_id, schedule.destination.state],
        ['.0.7'+table_id, 1],
        ['.0.8'+table_id, profile_ids],
        ['.0.10'+table_id, 1],
        ['.0.9'+table_id, 2],
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
                                                     '_schedule_id' => schedule.id
    rescue Exception => error
      Yell.new(:gelf, :facility => 'netmetric').error 'Nao foi possivel enviar o managerTable: '+error.to_s,
                                                      '_schedule_id' => schedule.id,
                                                      '_error' => error
      raise SnmpLegacyJobException, 'Erro na execução do job snmp_legacy ao configurar o gerente'
    end
  end

  #seta a managerTable
  def self.agent_setup(profiles, schedule)
    if schedule.destination.type == 'android'
      Yell.new(:gelf, :facility => 'netmetric').info 'Agentes Android devem ter o gerente configurado no próprio aparelho.',
                                                     '_schedule_id' => schedule.id
      return nil
    end

    real_ipaddress = schedule.destination.real_ipaddress

    ports = ''
    protocol_ids = ''
    profiles.each do |profile|
      ports << '1200'+profile.id.to_s + ' '
      protocol_id = JSON.load(profile.config_parameters)['profile']['data'].at(9).to_a.at(0).at(1)
      protocol_ids << protocol_id.to_s + ' '
    end
    ports = ports.strip
    protocol_ids = protocol_ids.strip
    table_id = schedule.source.id.to_s

    data_array = [
        ['.0.3'+table_id, 6],
        ['.0.0'+table_id, schedule.source.real_ipaddress],
        ['.0.1'+table_id, ports],
        ['.0.2'+table_id, protocol_ids],
        ['.0.3'+table_id, 2],
    ]


    base_index = '1.3.6.1.4.1.12000.10'

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
      Yell.new(:gelf, :facility => 'netmetric').info "Agente #{schedule.destination.name} configurado para receber testes do Ggente #{schedule.source.name}",
                                                     '_schedule_id' => schedule.id
    rescue Exception => error
      Yell.new(:gelf, :facility => 'netmetric').error 'Nao foi possivel enviar o agentTable: '+error.to_s,
                                                      '_schedule_id' => schedule.id,
                                                      '_error' => error
      raise SnmpLegacyJobException, 'Erro na execução do job snmp_legacy ao configurar o agente'
    end
  end
end