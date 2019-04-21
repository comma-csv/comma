# frozen_string_literal: true

class Array
  def to_comma(style = :default)
    Comma::Generator.new(self, style).run(:each)
  end
end
