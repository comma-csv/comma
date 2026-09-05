# frozen_string_literal: true

module Comma
  module CollectionExport
    def to_comma(style = :default)
      Comma::Generator.new(self, style).run(:each)
    end
  end
end
