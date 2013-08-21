# -*- coding: utf-8 -*-
require 'rubygems'
$LOAD_PATH.unshift(File.expand_path(File.join(*%w{.. .. lib}), __FILE__))

begin
  require 'rails'
rescue LoadError
end

require 'simplecov'
SimpleCov.start do
  add_filter  "spec"
  use_merging true
  merge_timeout 600
end

require 'bundler/setup'
Bundler.require

if defined? Rails
  #Conditionally load rails app for controller tests if rspec-rails gem is installed
  require "rails_app/config/environment"
  require 'rspec/rails'
  ENV["RAILS_ENV"] = "test"

  SimpleCov.command_name 'rspec:with_rails'

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

else
  # Normal tests : Basic active record + support only calls
  SimpleCov.command_name 'rspec:without_rails'

  begin
    require 'active_record'
    config = YAML::load(IO.read(File.dirname(__FILE__) + '/rails_app/config/database.yml'))
    ActiveRecord::Base.establish_connection(config['test'])
  rescue LoadError
  end

  begin
    require 'mongoid'
    Mongoid.configure do |mconfig|
      mconfig.sessions = {:default => {:hosts => ['localhost:27017'], :database => 'comma_test'}}
    end
  rescue LoadError
  end
end

require File.expand_path('../../spec/non_rails_app/ruby_classes' , __FILE__)
