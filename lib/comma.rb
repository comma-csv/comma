# frozen_string_literal: true

require 'csv'
CSV_HANDLER = CSV

module Comma
  DEFAULT_OPTIONS = {
    write_headers: true,
    style: :default
  }.freeze
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

# Load into Rails controllers
ActiveSupport.on_load(:action_controller) do
  if defined?(ActionController::Renderers) && ActionController::Renderers.respond_to?(:add)
    ActionController::Renderers.add :csv do |obj, options|
      filename    = options[:filename]  || 'data'
      extension   = options[:extension] || 'csv'

      mime_type = if Rails.version >= '5.0.0'
                    options[:mime_type] || Mime[:csv]
                  else
                    options[:mime_type] || Mime::CSV
                  end

      # Capture any CSV optional settings passed to comma or comma specific options
      csv_options = options.slice(*CSV_HANDLER::DEFAULT_OPTIONS.merge(Comma::DEFAULT_OPTIONS).keys)
      csv_options = csv_options.each_with_object({}) do |(k, v), h|
        # XXX: Convert string to boolean
        h[k] = case k
               when :write_headers
                 (v != 'false') if v.is_a?(String)
               else
                 v
               end
      end
      data = obj.to_comma(csv_options)
      disposition = "attachment; filename=\"#{filename}.#{extension}\""
      send_data data, type: mime_type, disposition: disposition
    end
  end
end
