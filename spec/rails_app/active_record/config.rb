# -*- coding: utf-8 -*-

ActiveRecord::Base.configurations = {'test' => {'adapter' => 'sqlite3', 'database' => ':memory:'}}
ActiveRecord::Base.establish_connection(:test)
