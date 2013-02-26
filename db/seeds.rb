# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#usuarios padrao, para primeiro acesso e testes
admin_role = Role.create({ name: 'admin', description: 'Administrador'})
normal_role = Role.create({ name: 'normal', description: 'Configurador' })
visualizador_role = Role.create({ name: 'visualizador', description: 'Visualizador'})

admin_user = User.new({ email: 'admin@netmetric.com', password: 'admin1', password_confirmation: 'admin1', adm_block: true})
normal_user = User.new({ email: 'normal@netmetric.com', password: 'normal1', password_confirmation: 'normal1', adm_block: true})
visualizador_user = User.new({ email: 'visualizador@netmetric.com', password: 'visualizador1', password_confirmation: 'visualizador1', adm_block: true})

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

Metric.create([
      { name: "Throughput TCP", description: "Vazão de dados sob TCP", order:1, plugin: "throughput_tcp", reverse: false },
      { name: "Throughput", description: "Vazão de dados sob UDP", order:2, plugin: "throughput", reverse: false },
      { name: "Throughput HTTP", description: "Vazão de dados sob HTTP", order:3, plugin: "throughput_http", reverse: false },
      { name: "RTT", description: "Latência ida e volta", order:4, plugin: "rtt", reverse: true },
      { name: "Perda", description: "Perda de pacotes transmitidos", order:5, plugin: "loss", reverse: true },
      { name: "Jitter", description: "Flutuação da latência", order:6, plugin: "jitter", reverse: true },
      { name: "OWD", description: "Latência Unidirecional", order:7, plugin: "owd", reverse: true },
      { name: "POM", description: "Pacotes fora de ordem", order:8, plugin: "pom", reverse: true },
])

#perfis de conexao e planos
conn3g = ConnectionProfile.new({ name_id: "3g-default", name: "3G Padrão", notes: "Perfil de conexão para redes 3G convencionais", conn_type: "mobile" })
conn3g.save!

plano3g = Plan.new({ name: "Vivo Internet (2012)", description: "Plano iniciado em 2012, sem a opção Plus (sem HDSPA+)", throughput_down: 1000, throughput_up:300})
plano3g.connection_profile = conn3g
plano3g.save!

conn4g = ConnectionProfile.new({ name_id: "4g-default", name: "4G", notes: "Perfil de conexão para redes 4G LTE", conn_type: "mobile" })
conn4g.save!

plano4g = Plan.new({ name: "Vivo Internet LTE", description: "Plano iniciado em 2013, utilizando LTE", throughput_down: 4000, throughput_up:1000})
plano4g.connection_profile = conn4g
plano4g.save!

connfixa = ConnectionProfile.new({ name_id: "fixed", name: "Banda Larga Fixa", notes: "Perfil para redes fixas (ADSL/Cable)", conn_type: "fixed"})
connfixa.save!

planospeedy = Plan.new({ name: "Vivo Speedy 10Mbps", description: "Plano Speedy ADSL de 10 mega", throughput_down: 10000, throughput_up: 512})
planospeedy.connection_profile = connfixa
planospeedy.save!

#limiares anatel
Threshold.create([
     { name: "SCM4/SMP10", description: "Taxa de Transmissão Instantanea", compliance_level: "0.95", compliance_period: "monthly", compliance_method: "quotient", goal_level: "0.2", goal_method: "median", goal_period: "daily-rush", metric_id: "3" },
     { name: "SCM5/SMP11", description: "Taxa de Transmissão Média", compliance_level: "0.6", compliance_period: "monthly", compliance_method: "mean", goal_level: "0.6", goal_method: "median", goal_period: "daily-rush", metric_id: "3" },
     { name: "SCM6", description: "Latência Bidirecional", compliance_level: "0.85", compliance_period: "monthly", compliance_method: "quotient", goal_level: "80.0", goal_method: "median", goal_period: "daily-rush", metric_id: "4" },
     { name: "SCM7", description: "Variação de Latência", compliance_level: "0.85", compliance_period: "monthly", compliance_method: "quotient", goal_level: "50.0", goal_method: "median", goal_period: "daily-rush", metric_id: "6" },
     { name: "SCM8", description: "% Pacotes Descartados", compliance_level: "0.85", compliance_period: "monthly", compliance_method: "quotient", goal_level: "0.02", goal_method: "raw", goal_period: "each-rush", metric_id: "5" },
     { name: "SCM9", description: "Disponibilidade", compliance_level: "0.85", compliance_period: "monthly", compliance_method: "quotient", goal_level: "0.99", goal_method: "availability", goal_period: "each", metric_id: "5" },
])
