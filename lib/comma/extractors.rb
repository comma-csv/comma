# csv do
#   grain_type :name
#   bhc_site :state, :name => 'Site'
#   bin_grade :code
#   
#   trade_price_per_ton
#   traded_quantity
#   created_at   
# end

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
  end
  
  class HeaderExtractor < Extractor
    
    def method_missing(sym, *args, &block)
      @results << sym.to_s.gsub(/\s/, ' ').humanize if args.blank?
      
      args.each do |arg|
        case arg
        when Hash
          arg.each do |k, v|
            @results << v.to_s.gsub(/\s/, ' ').humanize
          end
        when Symbol
          @results << arg.to_s.gsub(/\s/, ' ').humanize
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
            @results << @instance.send(sym).send(k).to_s
          end
        when Symbol
          @results << @instance.send(sym).send(arg).to_s
        else
          raise "Unknown data symbol #{arg.inspect}"
        end
      end
    end
  end
end
