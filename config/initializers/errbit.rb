# Require the hoptoad_notifier gem in your App.
# ---------------------------------------------
#
# Rails 3 - In your Gemfile
# gem 'airbrake'
#
# Rails 2 - In environment.rb
# config.gem 'airbrake'
#
# Then add the following to config/initializers/errbit.rb
# -------------------------------------------------------

Airbrake.configure do |config|
  config.api_key = '39a47829635326598561d4efecd6a83e'
  config.host    = 'fringe.inf.ufrgs.br'
  config.port    = 443
  config.secure  = config.port == 443
end

module Airbrake
  class Sender
    NOTICES_URI = '/errbit/notifier_api/v2/notices/'.freeze
  end
end

# Set up Javascript notifications
# -------------------------------
#
# To receive notifications for javascript errors,
# you should add <%= airbrake_javascript_notifier %> to the top of your layouts.
#
# Testing
# -------
#
# Rails 2 - you'll need to vendor airbrake to get the rake tasks
# rake gems:unpack GEM=airbrake
#
# Run:
# rake airbrake:test
# refresh this page