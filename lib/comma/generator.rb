module Comma

  class Generator

    def initialize(instance, style)
      @instance = instance
      @style    = style
      @options  = {}

      if @style.is_a? Hash
        @options                  = @style.clone
        @style                    = @options.delete(:style) || Comma::DEFAULT_OPTIONS[:style]
        @filename                 = @options.delete(:filename)
      end
    end

    def run(iterator_method)
      if @filename
        CSV_HANDLER.open(@filename, 'w', @options){ |csv| append_csv(csv, iterator_method) } and return true
      else
        CSV_HANDLER.generate(@options){ |csv| append_csv(csv, iterator_method) }
      end
    end

    private

    def append_csv(csv, iterator_method)
      return '' if @instance.empty?
      unless @options.has_key?(:write_headers) && !@options[:write_headers]
        csv << @instance.first.to_comma_headers(@style)
      end
      @instance.send(iterator_method) do |object|
        csv << object.to_comma(@style)
      end
    end

  end
end
