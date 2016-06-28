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

      @results << header_string(sym) if args.blank?
      args.each do |arg|
        case arg
        when Hash
          arg.each do |k, v|
            @results << ((v.is_a? String) ? v : header_string(sym))
          end
        when Symbol
          @results << header_string(arg)
        when String
          @results << arg
        else
          raise "Unknown header symbol #{arg.inspect}"
        end
      end
    end

    def header_string attribute
      key = "activerecord.attributes.#{@instance.class.to_s.underscore}.#{attribute.to_s}"
      ap key
      I18n.t(key, default: attribute.to_s.humanize)
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
            if block
              @results << (@instance.send(sym).nil? ? '' : yield(@instance.send(sym).send(k)).to_s )
            else
              @results << (@instance.send(sym).nil? ? '' : @instance.send(sym).send(k).to_s )
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
        else
          raise "Unknown data symbol #{arg.inspect}"
        end
      end
    end
  end
end
