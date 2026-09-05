# frozen_string_literal: true

require 'active_support'
require 'active_support/lazy_load_hooks'

ActiveSupport.on_load(:active_record) do
  require 'comma/relation' if defined?(ActiveRecord::Relation)
end

ActiveSupport.on_load(:mongoid) do
  require 'comma/mongoid'
end

ActiveSupport.on_load(:action_controller) do
  require 'comma/rails/renderer'
end
