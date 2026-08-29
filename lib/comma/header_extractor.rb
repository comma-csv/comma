# frozen_string_literal: true

require 'comma/extractor'
require 'active_support'
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

    def __static_column__(header = '', &_block)
      @results << header
    end

    private

    def extract_column(method, association: nil, label: nil, **)
      model_class = @instance.class
      target_class = association ? get_association_class(model_class, association) : model_class
      value_humanizer.call(label || method, target_class)
    end

    def column_kind
      'header'
    end

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
