# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#usuarios padrao, para primeiro acesso e testes
admin_role = Role.find_or_create_by_name({ name: 'admin', description: 'Administrador'})
normal_role = Role.find_or_create_by_name({ name: 'normal', description: 'Configurador' })
visualizador_role = Role.find_or_create_by_name({ name: 'visualizador', description: 'Visualizador'})

admin_user = User.find_or_create_by_email({ email: 'admin@netmetric.com', password: 'admin1', password_confirmation: 'admin1', adm_block: true})
normal_user = User.find_or_create_by_email({ email: 'normal@netmetric.com', password: 'normal1', password_confirmation: 'normal1', adm_block: true})
visualizador_user = User.find_or_create_by_email({ email: 'visualizador@netmetric.com', password: 'visualizador1', password_confirmation: 'visualizador1', adm_block: true})

admin_user.skip_confirmation!
normal_user.skip_confirmation!
visualizador_user.skip_confirmation!

admin_user.roles << admin_role
admin_user.save!
normal_user.roles << normal_role
normal_user.save!
visualizador_user.roles << visualizador_role
visualizador_user.save!

#metricas
metrics = [
      { name: "Throughput TCP", description: "Vazão de dados sob TCP", order:1, plugin: "throughput_tcp", reverse: false, view_unit: 'kb/s', db_unit: 'b/s', metric_type: 'active' },
      { name: "Throughput UDP", description: "Vazão de dados sob UDP", order:2, plugin: "throughput", reverse: false, view_unit: 'kb/s', db_unit: 'b/s', metric_type: 'active' },
      { name: "Throughput HTTP", description: "Vazão de dados sob HTTP", order:3, plugin: "throughput_http", reverse: false, view_unit: 'kb/s', db_unit: 'b/s', metric_type: 'active' },
      { name: "RTT", description: "Latência ida e volta", order:4, plugin: "rtt", reverse: true, view_unit: 'ms', db_unit: 's', metric_type: 'active' },
      { name: "Perda", description: "Perda de pacotes transmitidos", order:5, plugin: "loss", reverse: true, view_unit: '%', db_unit: '%', metric_type: 'active' },
      { name: "Jitter", description: "Flutuação da latência", order:6, plugin: "jitter", reverse: true, view_unit: 'ms', db_unit: 's', metric_type: 'active' },
      { name: "OWD", description: "Latência Unidirecional", order:7, plugin: "owd", reverse: true, view_unit: 'ms', db_unit: 's', metric_type: 'active' },
      { name: "POM", description: "Pacotes fora de ordem", order:8, plugin: "pom", reverse: true, view_unit: '%', db_unit: '%', metric_type: 'active' },
      { name: "Disponibilidade", description: "Disponibilidade total da sonda", order:9, plugin: "availability", reverse: false, view_unit: '%', db_unit: '%', metric_type: 'active' },
      { name: "DNS - Tempo de Resposta", description: "Tempo de Resposta para uma query DNS", order:10, plugin: "dns-response-time", reverse: true, view_unit: 'ms', db_unit: 's', metric_type: 'dns' },
      { name: "DNS - Eficiência", description: "Porcentagem de Respostas positivas do servidor DNS", order:11, plugin: "dns-efficiency", reverse: true, view_unit: '%', db_unit: '%', metric_type: 'dns_eficiency' },
      { name: "DNS - Detalhes", description: "Detalhes das falhas de DNS por categorias definidas na RFC1035", order:12, plugin: "dns-details", reverse: true, view_unit: '%', db_unit: '%', metric_type: 'dns_detail' },
      { name: "Sites - Taxa de Aquisição", description: "Tempo de download dos sites", order:13, plugin: "sites-throughput", reverse: false, view_unit: 'Mb/s', db_unit: 'kb/s', metric_type: 'webload' },
      { name: "Sites - Tempo de Carga", description: "Tempo de carga dos sites", order:14, plugin: "sites-loadtime", reverse: true, view_unit: 'ms', db_unit: 'ms', metric_type: 'webload' },
      { name: "Sites - Número de Objetos", description: "Número de objetos carregados para um determinado site", order:13, plugin: "sites-objects-qty", reverse: true, view_unit: '', db_unit: '', metric_type: 'webload' },
]

metrics.each do |metric|
  Metric.find_or_create_by_plugin(metric).save!
end


#perfis de conexao e planos
conn3g = ConnectionProfile.find_or_create_by_name_id({ name_id: "3g-default", name: "3G", notes: "Perfil de conexão para redes 3G", conn_type: "mobile" })
conn3g.save!

plano3g = Plan.find_or_create_by_name({ name: "Vivo Internet (2012)", description: "Plano iniciado em 2012, sem a opção Plus (sem HDSPA+)", throughput_down: 1000, throughput_up:300})
plano3g.connection_profile = conn3g
plano3g.save!

conn4g = ConnectionProfile.find_or_create_by_name_id({ name_id: "4g-default", name: "4G", notes: "Perfil de conexão para redes 4G LTE", conn_type: "mobile" })
conn4g.save!

plano4g = Plan.find_or_create_by_name({ name: "Vivo Internet 4G", description: "Plano iniciado em 2013, utilizando LTE", throughput_down: 4000, throughput_up:1000})
plano4g.connection_profile = conn4g
plano4g.save!

connfixa = ConnectionProfile.find_or_create_by_name_id({ name_id: "fixed", name: "Banda Larga Fixa", notes: "Perfil para redes fixas (ADSL/Cable)", conn_type: "fixed"})
connfixa.save!

planospeedy = Plan.find_or_create_by_name({ name: "Vivo Speedy 10Mbps", description: "Speedy ADSL 10Mbps", throughput_down: 10000, throughput_up: 512})
planospeedy.connection_profile = connfixa
planospeedy.save!

#limiares anatel
Threshold.find_or_create_by_name([
     { name: "SCM4/SMP10", description: "Taxa de Transmissão Instantânea", compliance_level: "0.95", compliance_period: "monthly", compliance_method: "quotient", goal_level: "0.2", goal_method: "median", goal_period: "daily-rush", metric_id: "3", base_year: '2013' },
     { name: "SCM5/SMP11", description: "Taxa de Transmissão Média", compliance_level: "0.6", compliance_period: "monthly", compliance_method: "mean", goal_level: "0.6", goal_method: "median", goal_period: "daily-rush", metric_id: "3", base_year: '2013' },
     { name: "SCM6", description: "Latência Bidirecional", compliance_level: "0.85", compliance_period: "monthly", compliance_method: "quotient", goal_level: "80.0", goal_method: "median", goal_period: "daily-rush", metric_id: "4", base_year: '2013' },
     { name: "SCM7", description: "Variação de Latência", compliance_level: "0.85", compliance_period: "monthly", compliance_method: "quotient", goal_level: "50.0", goal_method: "median", goal_period: "daily-rush", metric_id: "6", base_year: '2013' },
     { name: "SCM8", description: "% Pacotes Descartados", compliance_level: "0.85", compliance_period: "monthly", compliance_method: "quotient", goal_level: "0.02", goal_method: "raw", goal_period: "each-rush", metric_id: "5", base_year: '2013' },
     { name: "SCM9", description: "Disponibilidade", compliance_level: "0.85", compliance_period: "monthly", compliance_method: "quotient", goal_level: "0.99", goal_method: "availability", goal_period: "each", metric_id: "5", base_year: '2013' },
])


