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

admin_user = User.new({ email: 'admin@netmetric.com', password: 'admin1', adm_block: true})
normal_user = User.new({ email: 'normal@netmetric.com', password: 'normal1', adm_block: true})

admin_user.skip_confirmation!
normal_user.skip_confirmation!

admin_user.roles << admin_role
admin_user.save!
normal_user.roles << normal_role
normal_user.save!

Metric.create([
      { name: "throughput", description: "Vazão de dados", order:2, plugin: "throughput", reverse: false },
      { name: "throughputTCP", description: "Vazão de dados sob TCP", order:1, plugin: "throughputTCP", reverse: false },
      { name: "capacity", description: "Capacidade no gargalo (experimental)", order:9, plugin: "capacity", reverse: false },
      { name: "rtt", description: "Latência ida e volta", order:3, plugin: "rtt", reverse: true },
      { name: "loss", description: "Perda de pacotes transmitidos", order:4, plugin: "loss", reverse: true },
              ])

conn3g = ConnectionProfile.new({ name_id: "3g-default", name: "3G Padrão", notes: "Perfil de conexão para redes 3G convencionais", conn_type: "mobile" })
conn3g.save!

plano3g = Plan.new({ name: "Vivo Internet (2012)", description: "Plano iniciado em 2012, sem a opção Plus (sem HDSPA+)", throughputDown: 1000, throughputUp:300})
plano3g.connection_profile = conn3g
plano3g.save!

conn4g = ConnectionProfile.new({ name_id: "4g-default", name: "4G", notes: "Perfil de conexão para redes 4G LTE", conn_type: "mobile" })
conn4g.save!

plano4g = Plan.new({ name: "Vivo Internet LTE", description: "Plano iniciado em 2013, utilizando LTE", throughputDown: 4000, throughputUp:100})
plano4g.connection_profile = conn4g
plano4g.save!