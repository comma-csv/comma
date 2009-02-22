require 'activesupport'
require 'fastercsv'
require 'comma/extractors'

class Array
  def to_comma
    FasterCSV.generate do |csv|
      csv << first.to_comma_headers
      each do |object| 
        csv << object.to_comma
      end
    end
  end
end

class Object
  def self.comma(&block)
    define_method :to_comma do
      Comma::DataExtractor.new(self, &block).results
    end

    define_method :to_comma_headers do
      Comma::HeaderExtractor.new(self, &block).results
    end
  end
end

if defined?(ActionController)
  module RenderAsCSV

    def self.included(base)
      base.send :include, InstanceMethods
      base.alias_method_chain :render, :csv
    end

    module InstanceMethods
      def render_with_csv(options = nil, extra_options = {}, &block)
        return render_without_csv(options, extra_options, &block) unless options and options[:csv]
        send_data Array(options[:csv]).to_comma
      end
    end

  end

  ActionController::Base.send :include, RenderAsCSV
end