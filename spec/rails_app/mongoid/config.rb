# frozen_string_literal: true

Mongoid.configure do |config|
  config.sessions = {
    default: {
      hosts: ['localhost:27017'], database: 'comma_test'
    }
  }
end
