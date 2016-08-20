# load the right csv library
if RUBY_VERSION >= '1.9'
  require 'csv'
  CSV_HANDLER = CSV
else
  begin
    gem 'fastercsv'
    require 'fastercsv'

    CSV_HANDLER = FasterCSV
  rescue LoadError => e
    raise "Error : FasterCSV not installed, please `gem install fastercsv` for faster processing on <Ruby 1.9"
  end
end

if defined? Rails and (Rails.version.split('.').map(&:to_i).first < 3)
  raise "Error - This Comma version only supports Rails 3.x. Please use a 2.x version of Comma for use with earlier rails versions."
end

module Comma
  DEFAULT_OPTIONS = {
      :write_headers => true,
      :style => :default
    }
end

require 'active_support/lazy_load_hooks'
ActiveSupport.on_load(:active_record) do
  require 'comma/relation' if defined?(ActiveRecord::Relation)
end

ActiveSupport.on_load(:mongoid) do
  require 'comma/mongoid'
end

require 'comma/data_mapper_collection' if defined? DataMapper

require 'comma/generator'
require 'comma/array'
require 'comma/object'

#Load into Rails controllers
ActiveSupport.on_load(:action_controller) do
  if defined?(ActionController::Renderers) && ActionController::Renderers.respond_to?(:add)
    ActionController::Renderers.add :csv do |obj, options|
      filename    = options[:filename]  || 'data'
      extension   = options[:extension] || 'csv'
      mime_type   = options[:mime_type] || Mime[:csv]
      #Capture any CSV optional settings passed to comma or comma specific options
      csv_options = options.slice(*CSV_HANDLER::DEFAULT_OPTIONS.merge(Comma::DEFAULT_OPTIONS).keys).each_with_object({}) do |(k, v), h|
        # XXX: Convert string to boolean
        h[k] = case k
        when :write_headers
          v = (v != 'false') if v.is_a?(String)
        else
          v
        end
      end
      send_data obj.to_comma(csv_options), :type => mime_type, :disposition => "attachment; filename=\"#{filename}.#{extension}\""
    end
  end
end
