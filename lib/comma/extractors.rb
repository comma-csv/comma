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

    def id
      method_missing(:id)
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
        else
          raise "Unknown header symbol #{arg.inspect}"
        end
      end
    end
  end

  class DataExtractor < Extractor

    def method_missing(sym, *args, &block)
      @results << @instance.send(sym).to_s if args.blank?

      args.each do |arg|
        case arg
        when Hash
          arg.each do |k, v|
            @results << (@instance.send(sym).nil? ? '' : @instance.send(sym).send(k).to_s )
          end
        when Symbol
            @results << ( @instance.send(sym).nil? ? '' : @instance.send(sym).send(arg).to_s )
        when String
          @results << @instance.send(sym).to_s
        else
          raise "Unknown data symbol #{arg.inspect}"
        end
      end
    end
  end
end
