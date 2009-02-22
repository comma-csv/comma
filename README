= COMMA

http://github.com/crafterm/comma

== DESCRIPTION:

Comma is a CSV (ie. comma separated values) generation extension for Ruby objects, that lets you seamlessly define a CSV output format via a small DSL. Comma works well on pure Ruby objects with attributes, as well as complex ones such as ActiveRecord objects with associations, extensions, etc. It doesnt distinguish between attributes, methods, associations, extensions, etc - they all are considered equal and invoked identically via the Comma DSL description.

When multiple objects in an Array are converted to CSV, the output includes generation of a header row reflected from names of the properties requested, or specified via the DSL.

An example Comma CSV enabled ActiveRecord class:

  class Book < ActiveRecord::Base
  
    # ================
    # = Associations =
    # ================
    has_many   :pages
    has_one    :isbn
    belongs_to :publisher
  
    # ===============
    # = CSV support =
    # ===============
    comma do

      name
      description
    
      pages :size => 'Pages'
      publisher :name
      isbn :number_10 => 'ISBN-10', :number_13 => 'ISBN-13'
      
    end

  end

Annotated, the comma description is as follows:

  # starts a Comma description block, generating 2 methods #to_comma and #to_comma_headers for this class.
  comma do

    # name, description are attributes of Book with the header being reflected as 'Name', 'Description'
    name
    description
  
    # pages is an association returning an array, :size is called on the association results, with the header name specifed as 'Pages'
    pages :size => 'Pages'
    
    # publisher is an association returning an object, :name is called on the associated object, with the reflected header 'Name'
    publisher :name
    
    # isbn is an association returning an object, :number_10 and :number_13 are called on the object with the specified headers 'ISBN-10' and 'ISBN-13'
    isbn :number_10 => 'ISBN-10', :number_13 => 'ISBN-13'
    
  end
  
In the above example, any of the declarations (name, description, pages, publisher, isbn, etc), could be methods, attributes, associations, etc - no distinction during configuration is required, as everything is invoked via Ruby's #send method.

Object values are automatically converted to strings via to_s allowing you to reuse any existing to_s methods on your objects (instead of having to call particular properties or define CSV specific output methods). Header names are also automatically humanized when reflected (eg. replacing _ characters with whitespace). The 'isbn' example above shows how multiple values can be added to the CSV output.

When used with Rails (ie. add 'comma' as a gem dependency), Comma automatically adds support for rendering CSV output in your controllers:

  class BooksController < ApplicationController

    def index
      respond_to do |format|
        format.csv { render :csv => Book.limited(50) }
      end
    end

  end

If you have any questions or suggestions for Comma, please feel free to contact me at crafterm@redartisan.com, all feedback welcome!
