require 'active_support'

# load the right csv library
if RUBY_VERSION >= '1.9'
  require 'csv'
  FasterCSV = CSV
else
  begin
    # try faster csv
    require 'fastercsv'
  rescue Exception => e
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
  require 'comma/association_proxy'
end

if defined?(ActionController)
  ActionController::Base.send :include, RenderAsCSV
end
