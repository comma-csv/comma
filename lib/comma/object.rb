class Object
  class_attribute :comma_formats

  def self.comma(style = :default, &block)
    (self.comma_formats ||= {})[style] = block
  end

  def to_comma(style = :default)
    raise "No comma format for class #{self.class} defined for style #{style}" unless self.comma_formats and self.comma_formats[style]
    Comma::DataExtractor.new(self, style, self.class.comma_formats).results
  end

  def to_comma_headers(style = :default)
    raise "No comma format for class #{self.class} defined for style #{style}" unless self.comma_formats and self.comma_formats[style]
    Comma::HeaderExtractor.new(self, style, self.class.comma_formats).results
  end
end
