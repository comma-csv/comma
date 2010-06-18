module Comma

  class Extractor

    def initialize(instance, &block)
      @instance = instance
      @block = block
      @results = []
    end

    def results
      instance_eval &@block
      @results
    end

    def id(*args)
      method_missing(:id, *args)
    end
  end

  class HeaderExtractor < Extractor

    def method_missing(sym, *args, &block)
      @results << sym.to_s.humanize if args.blank?
      args.each do |arg|
        case arg
        when Hash
          arg.each do |k, v|
            @results << ((v.is_a? String) ? v : v.to_s.humanize)
          end
        when Symbol
          @results << arg.to_s.humanize
        when String
          @results << arg
        when Array
          @results << arg.collect(&:to_s).collect(&:titleize).join(' ')
        else
          raise "Unknown header symbol #{arg.inspect}"
        end
      end
    end
  end

  class DataExtractor < Extractor

    def method_missing(sym, *args, &block)
      if args.blank?
        result = block ? yield(@instance.send(sym)) : @instance.send(sym)
        @results << result.to_s
      end

      args.each do |arg|
        case arg
        when Hash
          arg.each do |k, v|
            obj = @instance.send(sym)
            if !obj
              @results << ''
              next
            else
              value = Proc === k ? k.call(obj) : obj.send(k)
              @results << (block ? (value.to_s) : value.to_s
            end
          end
        when Symbol
          if block
            @results << (@instance.send(sym).nil? ? '' : yield(@instance.send(sym).send(arg)).to_s)
          else
            @results << ( @instance.send(sym).nil? ? '' : @instance.send(sym).send(arg).to_s )
          end
        when String
          @results << (block ? yield(@instance.send(sym)) : @instance.send(sym)).to_s
        when Array
          @results << (@instance.send(sym).nil? ? '' : arg.compact.inject(@instance.send(sym)) { |result, element| result.try(element) || '' })
        else
          raise "Unknown data symbol #{arg.inspect}"
        end
      end
    end
  end
end
