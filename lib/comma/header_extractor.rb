# frozen_string_literal: true

require 'comma/extractor'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/date_time/conversions'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/inflections'

module Comma
  class HeaderExtractor < Extractor
    class_attribute :value_humanizer

    DEFAULT_VALUE_HUMANIZER = lambda do |value, _model_class|
      value.is_a?(String) ? value : value.to_s.humanize
    end
    self.value_humanizer = DEFAULT_VALUE_HUMANIZER

    def method_missing(sym, *args, &_block)
      model_class = @instance.class
      @results << value_humanizer.call(sym, model_class) if args.blank?
      args.each do |arg|
        case arg
        when Hash
          arg.each do |_k, v|
            @results << value_humanizer.call(v, get_association_class(model_class, sym))
          end
        when Symbol
          @results << value_humanizer.call(arg, get_association_class(model_class, sym))
        when String
          @results << value_humanizer.call(arg, model_class)
        else
          raise "Unknown header symbol #{arg.inspect}"
        end
      end
    end

    def __static_column__(header = '', &_block)
      @results << header
    end

    private

    def get_association_class(model_class, association)
      return unless model_class.respond_to?(:reflect_on_association)

      begin
        model_class.reflect_on_association(association)&.klass
      rescue ArgumentError, NameError
        # Since Rails 5.2, ArgumentError is raised.
        nil
      end
    end
  end
end
