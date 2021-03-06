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
  config.api_key = '97da2c5ee66e8c1cdafc40459b5483a9'
  config.host    = 'localhost'
  config.port    = 80
  config.secure  = config.port == 443
end



module Airbrake
  class Sender
    v, $VERBOSE = $VERBOSE, nil
    NOTICES_URI = '/errbit/notifier_api/v2/notices/'.freeze
    $VERBOSE = v
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
