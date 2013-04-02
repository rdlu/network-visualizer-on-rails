ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require "minitest/spec"
require "minitest/pride"
require "minitest/autorun"
require "minitest/matchers"

Turn.config do |c|
 # use one of output formats:
 # :outline  - turn's original case/test outline mode [default]
 # :progress - indicates progress with progress bar
 # :dotted   - test/unit's traditional dot-progress mode
 # :pretty   - new pretty reporter
 # :marshal  - dump output as YAML (normal run mode only)
 # :cue      - interactive testing
 c.format  = :pretty
 # turn on invoke/execute tracing, enable full backtrace
 c.trace   = true
 # use humanized test names (works only with :outline format)
 # c.natural = true
end

# define fixtures module
module MiniTest::Rails::Fixtures
  def self.included(klass)
    klass.class_eval do
      include ActiveSupport::Testing::SetupAndTeardown
      include ActiveRecord::TestFixtures
      self.fixture_path = File.join(Rails.root, "test", "fixtures")
    end
  end
end

# include some stuff to be used by all specs
class MiniTest::Rails::Spec
  # cheat to make #context method available
  class << self
    alias :context :describe
  end
end

# make fixtures and shoulda matchers available within models spec
class MiniTest::Rails::Model
  include MiniTest::Rails::Fixtures
  include Shoulda::Matchers::ActiveRecord
  extend Shoulda::Matchers::ActiveRecord
  include Shoulda::Matchers::ActiveModel
  extend Shoulda::Matchers::ActiveModel
end

# make #describe BDD style available
MiniTest::Spec.register_spec_type MiniTest::Rails::Model do |desc|
  desc.constantize < ActiveRecord::Base
end

