require 'activesupport'
require 'comma/extractors'

if RUBY_VERSION =~ /^1.9/
  require 'csv'
  FasterCSV = CSV
else
  require 'fastercsv'
end

class Array
  def to_comma(style = :default)
    options = {}

    if style.is_a? Hash
      options = style.clone
      style = options.delete(:style)||:default
      filename = options.delete(:filename)
    end

    if filename
      FasterCSV.open(filename, 'w'){ |csv| append_csv(csv, style) }
    else
      FasterCSV.generate(options){ |csv| append_csv(csv, style) }
    end
  end

  private
  def append_csv(csv, style)
    return "" if empty?
    csv << first.to_comma_headers(style) # REVISIT: request to optionally include headers
    each do |object|
      csv << object.to_comma(style)
    end
  end
end

class Object
  class_inheritable_accessor :comma_formats
  
  def self.comma(style = :default, &block)
    (self.comma_formats ||= {})[style] = block
  end
  
  def to_comma(style = :default)
    raise "No comma format for class #{self.class} defined for style #{style}" unless self.comma_formats and self.comma_formats[style]
    Comma::DataExtractor.new(self, &self.comma_formats[style]).results
  end
  
  def to_comma_headers(style = :default)
    raise "No comma format for class #{self.class} defined for style #{style}" unless self.comma_formats and self.comma_formats[style]
    Comma::HeaderExtractor.new(self, &self.comma_formats[style]).results
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
        return render_without_csv(options, extra_options, &block) unless options.is_a?(Hash) and options[:csv]
        data = options.delete(:csv)
        style = options.delete(:style) || :default
        send_data Array(data).to_comma(style), options.merge(:type => :csv)
      end
    end

  end

  ActionController::Base.send :include, RenderAsCSV
end
