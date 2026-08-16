# frozen_string_literal: true

require 'comma/data_extractor'
require 'comma/header_extractor'

class Object
  class << self
    def comma(style = :default, &block)
      own_comma_formats[style] = block
    end

    def comma_formats
      classes_with_own_formats.reverse_each.each_with_object({}) do |klass, formats|
        formats.merge!(klass.instance_variable_get(:@own_comma_formats))
      end
    end

    private

    def own_comma_formats
      @own_comma_formats ||= {}
    end

    def classes_with_own_formats
      classes = []
      klass = self
      while klass
        classes << klass if klass.instance_variable_defined?(:@own_comma_formats)
        klass = klass.superclass
      end
      classes
    end
  end

  def comma_formats
    self.class.comma_formats
  end

  def to_comma(style = :default)
    extract_with(Comma::DataExtractor, style)
  end

  def to_comma_headers(style = :default)
    extract_with(Comma::HeaderExtractor, style)
  end

  private

  def extract_with(extractor_class, style = :default)
    raise_unless_style_exists(style)
    extractor_class.new(self, style, comma_formats).results
  end

  def raise_unless_style_exists(style)
    return if comma_formats[style]

    raise "No comma format for class #{self.class} defined for style #{style}"
  end
end
