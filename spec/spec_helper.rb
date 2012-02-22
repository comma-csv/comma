require 'rubygems'
require 'rspec'
require 'simplecov'
SimpleCov.start

require 'active_record'
ActiveRecord::ActiveRecordError # http://tinyurl.com/24f84gf

$:.unshift(File.dirname(__FILE__) + '/../lib')

config = YAML::load(IO.read(File.dirname(__FILE__) + '/support/database.yml'))
ActiveRecord::Base.establish_connection(config['test'])

require 'comma'

class Book
  attr_accessor :name, :description, :isbn

  def initialize(name, description, isbn)
    @name, @description, @isbn = name, description, isbn
  end

  comma do
    name 'Title'
    description

    isbn :authority => :issuer
    isbn :number_10 => 'ISBN-10'
    isbn :number_13 => 'ISBN-13'
  end

  comma :brief do
    name
    description
  end
end

class Isbn
  attr_accessor :number_10, :number_13

  def initialize(isbn_10, isbn_13)
    @number_10, @number_13 = isbn_10, isbn_13
  end

  def authority; 'ISBN'; end
end
