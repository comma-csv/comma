# load the right csv library
if RUBY_VERSION >= '1.9'
  require 'csv'
  CSV_HANDLER = CSV
else
  raise "Error - This Comma version only supports Ruby 1.9. Please use an older version."
end

if defined? Rails and (Rails.version.split('.').map(&:to_i).first < 3)
  raise "Error - This Comma version only supports Rails 3.x. Please use a 2.x version of Comma for use with earlier rails versions."
end

require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/module/delegation'
require 'comma/relation' if defined?(ActiveRecord::Relation)

require 'comma/extractors'
require 'comma/generator'
require 'comma/array'
require 'comma/object'

#Load into Rails controllers
if defined?(ActionController::Renderers) && ActionController::Renderers.respond_to?(:add)
  ActionController::Renderers.add :csv do |obj, options|
    filename    = options[:filename] || 'data'
    #Capture any CSV optional settings passed to comma
    csv_options = options.slice(*CSV_HANDLER::DEFAULT_OPTIONS.merge(:write_headers => nil).keys)

    send_data obj.to_comma(csv_options), :type => Mime::CSV, :disposition => "attachment; filename=#{filename}.csv"
  end
end
