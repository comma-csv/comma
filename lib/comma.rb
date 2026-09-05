# frozen_string_literal: true

require 'csv'
require 'logger'
CSV_HANDLER = CSV

module Comma
  DEFAULT_OPTIONS = {
    write_headers: true,
    style: :default
  }.freeze
end

require 'comma/data_mapper_collection' if defined? DataMapper

require 'comma/options'
require 'comma/generator'
require 'comma/array'
require 'comma/object'

require 'comma/rails'
