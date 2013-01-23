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

admin_user = User.new({ email: 'admin@netmetric.com', password: 'admin1'})
normal_user = User.new({ email: 'normal@netmetric.com', password: 'normal1'})

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

conn3g = ConnectionProfile.new({ name: "3g-default", description: "3G Padrão", notes: "Perfil de conexão para redes 3G convencionais", type: "mobile" })
conn3g.save!

plano3g = Plan.new({ name: "Vivo Internet (2012)", description: "Plano iniciado em 2012, sem a opção Plus (sem HDSPA+)", throughputDown: 1000, throughputUp:300})
plano3g.connection_profile = conn3g
plano3g.save!