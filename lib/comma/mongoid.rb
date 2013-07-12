#Conditionally set to_comma on Mongoid records if mongoid gem is installed
begin
  require 'mongoid'
  class Mongoid::Criteria
    def to_comma(style = :default)
      Comma::Generator.new(self, style).run(:each)
    end
  end
rescue LoadError
end


