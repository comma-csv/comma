# -*- coding: utf-8 -*-
require 'comma/extractor'

module Comma

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
