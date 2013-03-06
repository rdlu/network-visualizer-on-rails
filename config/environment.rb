#somente necessario se for proxy via nginx
#ENV["RAILS_RELATIVE_URL_ROOT"] = "/mom"

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
MomRails::Application.initialize!

require "extend_string"
require "extend_date"