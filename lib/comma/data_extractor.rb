# frozen_string_literal: true

require 'comma/extractor'

module Comma
  class DataExtractor < Extractor
    class ExtractValueFromInstance
      def initialize(instance)
        @instance = instance
      end

      def extract(sym, &block)
        yield_block_with_value(extract_value(sym), &block)
      end

      private

      def yield_block_with_value(value, &block)
        block ? yield(value) : value
      end

      def extract_value(method)
        extraction_object.send(method)
      end

      def extraction_object
        @instance
      end
    end

    class ExtractValueFromAssociationOfInstance < ExtractValueFromInstance
      def initialize(instance, association_name)
        super(instance)
        @association_name = association_name
      end

      private

      def extraction_object
        @instance.send(@association_name) || null_association
      end

      def null_association
        @null_association ||= Class.new(Class.const_defined?(:BasicObject) ? ::BasicObject : ::Object) do
          def method_missing(_symbol, *_args, &_block)
            nil
          end
        end.new
      end
    end

    def method_missing(sym, *args, &block)
      @results << ExtractValueFromInstance.new(@instance).extract(sym, &block) if
        args.blank?

      args.each do |arg|
        case arg
        when Hash
          arg.each do |k, _v|
            @results << ExtractValueFromAssociationOfInstance.new(@instance, sym).extract(k, &block)
          end
        when Symbol
          @results << ExtractValueFromAssociationOfInstance.new(@instance, sym).extract(arg, &block)
        when String
          @results << ExtractValueFromInstance.new(@instance).extract(sym, &block)
        else
          raise "Unknown data symbol #{arg.inspect}"
        end
      end
    end

    def __static_column__(_header = nil, &block)
      @results << (block ? yield(@instance) : nil)
    end
  end
end
