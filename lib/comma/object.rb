class Object
  if Class.respond_to?(:class_attribute)
    class_attribute :comma_formats
  else
    #TODO : Rails 2.3.x Deprecation
    #Deprecated method for class accessors - Maintained for those still on Rails 2.3.x
    class_inheritable_accessor :comma_formats
  end

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
