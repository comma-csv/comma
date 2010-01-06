# conditional loading of activesupport
if defined? Rails and Rails.version < '2.3.5'
  require 'activesupport' 
else 
  require 'active_support/core_ext/class/inheritable_attributes'
end

# load the right csv library
if RUBY_VERSION >= '1.9'
  require 'csv' 
  FasterCSV = CSV
else 
  begin
    # try faster csv
    require 'fastercsv'
  rescue Error => e
    if defined? Rails
      Rails.logger.info "FasterCSV not installed, falling back on CSV"
    else
      puts "FasterCSV not installed, falling back on CSV"
    end
    require 'csv'
    FasterCSV = CSV
  end
end

require 'comma/extractors'
require 'comma/generator'
require 'comma/array'
require 'comma/object'
require 'comma/render_as_csv'

if defined?(ActiveRecord)
  require 'comma/named_scope'
end

if defined?(ActionController)
  ActionController::Base.send :include, RenderAsCSV
end
