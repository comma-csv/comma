module Comma

  class Extractor

    def initialize(instance, &block)
      @instance = instance
      @block = block
      @results = []
    end

    def results
      instance_eval &@block
      @results.map { |r| convert_to_data_value(r) }
    end

    def id(*args, &block)
      method_missing(:id, *args, &block)
    end

    private

    def convert_to_data_value(result)
      result.nil? ? result : result.to_s
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

    def __static_column__(header = '', &block)
      @results << header
    end
  end

  class DataExtractor < Extractor

    def method_missing(sym, *args, &block)
      if args.blank?
        @results << yield_block_with_value(
                      extract_value_from_object(@instance, sym), &block)
      end

      args.each do |arg|
        case arg
        when Hash
          arg.each do |k, v|
            @results << yield_block_with_value(
                          extract_value_from_object(
                            get_association(@instance, sym), k), &block)
          end
        when Symbol
          @results << yield_block_with_value(
                        extract_value_from_object(
                          get_association(@instance, sym), arg), &block)
        when String
          @results << yield_block_with_value(
              extract_value_from_object(@instance, sym), &block)
        else
          raise "Unknown data symbol #{arg.inspect}"
        end
      end
    end

    def __static_column__(header = nil, &block)
      @results << (block ? yield : nil)
    end

    private

    def yield_block_with_value(value, &block)
      block ? yield(value) : value
    end

    def extract_value_from_object(object, method)
      object.send(method)
    end

    def get_association(model, association_name)
      model.send(association_name) || NullAssociation.new
    end

  end

  class NullAssociation < Class.const_defined?(:BasicObject) ? ::BasicObject : ::Object
    def method_missing(symbol, *args, &block)
      nil
    end
  end

end
