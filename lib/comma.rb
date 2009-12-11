if defined? Rails and Rails.version < '2.3.5'
  require 'activesupport' 
else 
  require 'active_support'
end

if RUBY_VERSION >= '1.9'
  require 'csv' 
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
  end
end

require 'comma/extractors'
require 'comma/array'
require 'comma/object'
require 'comma/renderascsv'

if defined?(ActionController)
  ActionController::Base.send :include, RenderAsCSV
end
