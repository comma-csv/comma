# frozen_string_literal: true

module Comma
  class CircularStyleReference < StandardError; end

  class Extractor
    def initialize(instance, style, formats)
      @instance = instance
      @style = style
      @formats = formats
      @results = []
      @style_stack = [style]
    end

    def results
      instance_eval(&@formats[@style])
      @results.map { |r| convert_to_data_value(r) }
    end

    def id(*args, &block)
      method_missing(:id, *args, &block)
    end

    def __use__(style)
      if @style_stack.include?(style)
        chain = (@style_stack + [style]).join(' -> ')
        raise Comma::CircularStyleReference, "Circular __use__ reference detected: #{chain}"
      end

      @style_stack.push(style)
      instance_eval(&@formats[style])
      @style_stack.pop
    end

    private

    def convert_to_data_value(result)
      result.nil? ? result : result.to_s
    end
  end
end
