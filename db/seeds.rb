# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Metric.create([
    { name: "throughput", description: "Vazão de dados", order:2, plugin: "throughput", reverse: false },
    { name: "throughputTCP", description: "Vazão de dados sob TCP", order:1, plugin: "throughputTCP", reverse: false },
    { name: "capacity", description: "Capacidade no gargalo (experimental)", order:9, plugin: "capacity", reverse: false },
    { name: "rtt", description: "Latência ida e volta", order:3, plugin: "rtt", reverse: true },
    { name: "loss", description: "Perda de pacotes transmitidos", order:4, plugin: "loss", reverse: true },
              ])