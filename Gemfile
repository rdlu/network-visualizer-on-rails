source 'https://rubygems.org'

gem 'rails', '3.2.12'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'

gem 'rails-i18n'
gem 'nokogiri'
gem 'geocoder'
gem 'devise'
gem 'cancan'
gem 'rolify'
gem 'jquery-rails'
gem 'pry-rails'
gem 'will_paginate', '~> 3.0'
gem 'has_scope'
gem 'snmp'
gem 'delayed_job_active_record'
gem 'yell-adapters-gelf'
gem 'yell-rails'
gem 'daemons'
gem 'foreigner' #sincroniza chaves estrangeiras para o banco de dados
gem 'airbrake'
gem 'highcharts-rails', '~> 2.3.5'
gem 'ruby-units'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
gem 'jbuilder'

# To use validator of ip
gem  'ipaddress'

# Memcached
gem 'dalli'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'less'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :require => 'v8'

  gem 'uglifier', '>= 1.3.0'
  gem 'bootstrap-sass'
  gem 'bootswatch-rails'
end

group :development do
  gem 'immigrant' #plugin do foreigner que regenera migrations com chaves estrangeiras em nivel de BD
  gem 'meta_request'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'yaml_db'
end

# Use unicorn as the app server
gem 'unicorn'

group :test, :development do
	gem 'rspec-rails'
	gem 'fabrication'
end

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

