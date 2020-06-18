# frozen_string_literal: true

require 'rubygems'
$LOAD_PATH.unshift(File.expand_path(File.join('..', '..', 'lib'), __FILE__))

require 'simplecov'
require 'coveralls'
SimpleCov.formatter = Coveralls::SimpleCov::Formatter
if defined? Rails
  SimpleCov.start('rails') do
    add_filter %r{^/spec/comma/rails/data_mapper_collection_spec\.rb$}
    add_filter %r{^/spec/comma/rails/mongoid_spec\.rb$}
  end
else
  SimpleCov.start do
    add_filter %r{^/spec/comma/rails/data_mapper_collection_spec\.rb}
    add_filter %r{^/spec/comma/rails/mongoid_spec\.rb}
    add_filter %r{^/spec/controllers/}
  end
end

require 'bundler/setup'
Bundler.require

require 'rspec/active_model/mocks'
require 'rspec/its'

begin
  require 'rails'
rescue LoadError
  warn 'rails not loaded'
end

%w[data_mapper mongoid active_record].each do |orm|
  begin
    require orm
    break
  rescue LoadError
    warn "#{orm} not loaded"
  end
end

if defined? Rails
  require 'rails_app/rails_app'
  require 'rspec/rails'
else
  require 'rails_app/data_mapper/config' if defined?(DataMapper)
  require 'rails_app/mongoid/config' if defined?(Mongoid)
  require 'rails_app/active_record/config' if defined?(ActiveRecord)
end

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |file| require file }

require File.expand_path('../spec/non_rails_app/ruby_classes', __dir__)
