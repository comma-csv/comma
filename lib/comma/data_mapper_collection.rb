# frozen_string_literal: true

if defined?(DataMapper)
  module DataMapper
    class Collection
      def to_comma(style = :default)
        Comma::Generator.new(self, style).run(:each)
      end
    end
  end
end
