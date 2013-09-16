# -*- coding: utf-8 -*-

Mongoid.configure do |config|
  config.sessions = {
    :default => {
      :hosts => ['localhost:27017'], :database => 'comma_test'
    }
  }
end
