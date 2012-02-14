# load the right csv library
if RUBY_VERSION >= '1.9'
  require 'csv'
  CSV_HANDLER = CSV
else
  begin
    # try faster csv
    require 'fastercsv'
    CSV_HANDLER = FasterCSV
  rescue Exception => e
    fail_message = "FasterCSV not installed, please `gem install fastercsv` for faster processing"
    if defined? Rails
      Rails.logger.info fail_message
    else
      puts fail_message
    end
    require 'csv'
    CSV_HANDLER = CSV
  end
end

#TODO : Rails 2.3.x Deprecation
# conditional loading of activesupport
if defined? Rails and (Rails.version.split('.').map(&:to_i) <=> [2,3,5]) < 0
  require 'activesupport'
else
  require 'active_support/core_ext/class/inheritable_attributes'
end

if defined?(ActiveRecord)
  require 'comma/association_proxy'

  #TODO : Rails 2.3.x Deprecation
  if defined?(ActiveRecord::Relation)
    #Rails 3.x relations
    require 'comma/relation'
  elsif defined?(ActiveRecord::NamedScope::Scope)
    #Rails 2.x scoping
    require 'comma/named_scope'
  end

end

require 'comma/extractors'
require 'comma/generator'
require 'comma/array'
require 'comma/object'
require 'comma/render_as_csv'

if defined?(RenderAsCSV) && defined?(ActionController)
  ActionController::Base.send :include, RenderAsCSV
end
