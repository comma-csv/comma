# -*- coding: utf-8 -*-
require 'comma/data_extractor'
require 'comma/header_extractor'

class Object
  class << self
    def comma(style = :default, &block)
      (@comma_formats ||= {})[style] = block
    end

    def comma_formats
      @comma_formats ||= begin
        if self == Object
          {}
        else
          self.superclass.comma_formats
        end
      end
    end
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
    formats = respond_to?(:comma_formats) ? self.comma_formats : self.class.comma_formats
    extractor_class.new(self, style, formats).results
  end

  def raise_unless_style_exists(style)
    formats = respond_to?(:comma_formats) ? self.comma_formats : self.class.comma_formats
    raise "No comma format for class #{self.class} defined for style #{style}" unless formats && formats[style]
  end
end
