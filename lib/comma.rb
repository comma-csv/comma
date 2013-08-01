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

#Enable class_attribute_accessor
require 'active_support/core_ext/class/inheritable_attributes'

# begin
#   require 'action_controller'
# rescue Exception => e
#   #Force load rails for specs until controller specs completed
# end

if defined?(ActiveRecord)
  require 'comma/association_proxy'
  require 'comma/named_scope'
end

require 'comma/extractors'
require 'comma/generator'
require 'comma/array'
require 'comma/gen'
require 'comma/object'
require 'comma/render_as_csv'

if defined?(RenderAsCSV) && defined?(ActionController)
  ActionController::Base.send :include, RenderAsCSV
end
