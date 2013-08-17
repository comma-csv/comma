require 'active_support/core_ext/class/attribute'

module Comma

  class Extractor

    def initialize(instance, style, formats)
      @instance = instance
      @style = style
      @formats = formats
      @results = []
    end

    def results
      instance_eval &@formats[@style]
      @results.map { |r| convert_to_data_value(r) }
    end

    def id(*args, &block)
      method_missing(:id, *args, &block)
    end

    def __use__(style)
      # TODO: prevent infinite recursion
      instance_eval(&@formats[style])
    end

    private

    def convert_to_data_value(result)
      result.nil? ? result : result.to_s
    end

  end

  class HeaderExtractor < Extractor

    class_attribute :value_humanizer

    DEFAULT_VALUE_HUMANIZER = lambda do |value, model_class|
      value.is_a?(String) ? value : value.to_s.humanize
    end
    self.value_humanizer = DEFAULT_VALUE_HUMANIZER

    def method_missing(sym, *args, &block)
      model_class = @instance.class
      @results << self.value_humanizer.call(sym, model_class) if args.blank?
      args.each do |arg|
        case arg
        when Hash
          arg.each do |k, v|
            @results << self.value_humanizer.call(v, get_association_class(model_class, sym))
          end
        when Symbol
          @results << self.value_humanizer.call(arg, get_association_class(model_class, sym))
        when String
          @results << self.value_humanizer.call(arg, model_class)
        else
          raise "Unknown header symbol #{arg.inspect}"
        end
      end
    end

    def __static_column__(header = '', &block)
      @results << header
    end

    private

    def get_association_class(model_class, association)
      model_class.respond_to?(:reflect_on_association) ?
        model_class.reflect_on_association(arg).klass : nil
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
      @results << (block ? yield(@instance) : nil)
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
