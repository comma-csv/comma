# frozen_string_literal: true

# Conditionally set to_comma on Mongoid records if mongoid gem is installed
begin
  require 'mongoid'

  module Mongoid
    class Criteria
      def to_comma(style = :default)
        Comma::Generator.new(self, style).run(:each)
      end
    end
  end
rescue LoadError # rubocop:disable Lint/HandleExceptions
end
