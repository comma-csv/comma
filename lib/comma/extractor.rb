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

      format = @formats.fetch(style) { raise "No comma format defined for style #{style}" }

      @style_stack.push(style)
      begin
        instance_eval(&format)
      ensure
        @style_stack.pop
      end
    end

    def method_missing(sym, *args, &block)
      @results << extract_column(sym, &block) if args.empty?

      args.each do |arg|
        case arg
        when Hash
          arg.each { |k, v| @results << extract_column(k, association: sym, label: v, &block) }
        when Symbol
          @results << extract_column(arg, association: sym, label: arg, &block)
        when String
          @results << extract_column(sym, label: arg, &block)
        else
          raise "Unknown #{column_kind} symbol #{arg.inspect}"
        end
      end
    end

    private

    def convert_to_data_value(result)
      result.nil? ? result : result.to_s
    end
  end
end
