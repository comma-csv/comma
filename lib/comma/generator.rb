# frozen_string_literal: true

module Comma
  class Generator
    def initialize(instance, style)
      @instance = instance
      parsed = Comma::Options.parse(style)
      @style = parsed[:style]
      @filename = parsed[:filename]
      @options = parsed[:csv]
    end

    def run(iterator_method)
      if @filename
        CSV_HANDLER.open(@filename, 'w', **@options) { |csv| append_csv(csv, iterator_method) } && (return true)
      else
        CSV_HANDLER.generate(**@options) { |csv| append_csv(csv, iterator_method) }
      end
    end

    private

    def append_csv(csv, iterator_method)
      return '' if @instance.empty?

      csv << @instance.first.to_comma_headers(@style) unless
        @options.key?(:write_headers) && !@options[:write_headers]
      @instance.send(iterator_method) do |object|
        csv << object.to_comma(@style)
      end
    end
  end
end
