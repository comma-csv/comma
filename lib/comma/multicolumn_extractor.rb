require "ostruct"

module Comma
  class MulticolumnExtractor
    attr_accessor :instance, :method, :block

    def initialize(instance, method, &block)
      @instance, @method, @block = instance, method, block
    end

    def extract_header
      cached_results.map(&:name)
    end

    def extract_values
      cached_results.map(&:value)
    end

    private
    def cached_results
      @cached_results ||= build_results
    end

    def build_results
      return unless block
      [].tap do |output|
        children = instance.send(method)
        [children].flatten.compact.each do |child|
          memo = Array.new
          block.call(memo, instance, child)
          memo.each{|m| output << OpenStruct.new(m) }
        end
      end
    end
  end
end
