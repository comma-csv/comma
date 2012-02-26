require 'rubygems'
require 'rspec'
require 'simplecov'
SimpleCov.start

begin
  #Load Rails
  require "rails_app/config/environment"
  require 'rspec/rails'
  ENV["RAILS_ENV"] = "test"

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|file| require file }

  load_schema = lambda {
    load "#{Rails.root.to_s}/db/schema.rb" # use db agnostic schema by default
    # ActiveRecord::Migrator.up('db/migrate') # use migrations
  }
  silence_stream(STDOUT, &load_schema)

  RSpec.configure do |config|
    config.use_transactional_fixtures = true
  end

rescue LoadError => e
  #Conditionally load rails app for controller tests if rspec-rails gem is installed
  # Normal tests : Basic active record + support only calls
  require 'active_record'

  config = YAML::load(IO.read(File.dirname(__FILE__) + '/rails_app/config/database.yml'))
  ActiveRecord::Base.establish_connection(config['test'])
end

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'comma'

require File.expand_path('../../spec/non_rails_app/ruby_classes' , __FILE__)