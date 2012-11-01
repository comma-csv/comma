#COMMA

http://github.com/crafterm/comma

##COMPATIBILITY
The mainline of this project builds gems to the 3.x version series, and is compatible and tested with :

* Ruby 1.8.7, 1.9.2, 1.9.3
* REE 1.8.7
* RBX 1.8
* Rails 3.x (all versions)

[![Build Status](https://secure.travis-ci.org/crafterm/comma.png)](http://travis-ci.org/crafterm/comma)

###LOOKING FOR RAILS 2?
*   Rails 2 is supported in the 'rails2' branch of this project, and versioned in the 2.x version of this gem. (https://github.com/crafterm/comma/tree/rails2).

##INSTALLATION

Comma is distributed as a gem, best installed via Bundler.

Include the gem in your Gemfile:

```Ruby
  gem "comma", "~> 3.0"
```

Or, if you want to live life on the edge, you can get master from the main comma repository:

```Ruby
  gem "comma",  :git => "git://github.com/crafterm/comma.git"
```

##DESCRIPTION:

Comma is a CSV (i.e. comma separated values) generation extension for Ruby objects, that lets you seamlessly define a CSV output format via a small DSL. Comma works well on pure Ruby objects with attributes, as well as complex ones such as ActiveRecord objects with associations, extensions, etc. It doesn't distinguish between attributes, methods, associations, extensions, etc. - they all are considered equal and invoked identically via the Comma DSL description. Multiple different CSV output descriptions can also be defined.

When multiple objects in an Array are converted to CSV, the output includes generation of a header row reflected from names of the properties requested, or specified via the DSL.

CSV can be a bit of a boring format - the motivation behind Comma was to have a CSV extension that was simple, flexible, and would treat attributes, methods, associations, etc., all the same without the need for any complex configuration, and also work on Ruby objects, not just ActiveRecord or other base class derivatives.

An example Comma CSV enabled ActiveRecord class:

```Ruby

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
     blurb 'Summary'

   end

 end

```

Annotated, the comma description is as follows:

```Ruby
 # starts a Comma description block, generating 2 methods #to_comma and
 # #to_comma_headers for this class.
 comma do

   # name, description are attributes of Book with the header being reflected as
   # 'Name', 'Description'
   name
   description

   # pages is an association returning an array, :size is called on the
   # association results, with the header name specified as 'Pages'
   pages :size => 'Pages'

   # publisher is an association returning an object, :name is called on the
   # associated object, with the reflected header 'Name'
   publisher :name

   # isbn is an association returning an object, :number_10 and :number_13 are
   # called on the object with the specified headers 'ISBN-10' and 'ISBN-13'
   isbn :number_10 => 'ISBN-10', :number_13 => 'ISBN-13'

   # blurb is an attribute of Book, with the header being specified directly
   # as 'Summary'
   blurb 'Summary'

 end

```

In the above example, any of the declarations (name, description, pages, publisher, isbn, blurb, etc), could be methods, attributes, associations, etc - no distinction during configuration is required, as everything is invoked via Ruby's #send method.

You can get the CSV representation of any object by calling the to_comma method, optionally providing a CSV description name to use.

Object values are automatically converted to strings via to_s allowing you to reuse any existing to_s methods on your objects (instead of having to call particular properties or define CSV specific output methods). Header names are also automatically humanised when reflected (eg. Replacing _ characters with whitespace). The 'isbn' example above shows how multiple values can be added to the CSV output.

Multiple CSV descriptions can also be specified for the same class, eg:

```Ruby

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
     blurb 'Summary'

   end

   comma :brief do

     name
     description
     blurb 'Summary'

   end

 end

```

You can specify which output format you would like to use via an optional parameter to to_comma:

```Ruby
 Book.limited(10).to_comma(:brief)
```

Specifying no description name to to_comma is equivalent to specifying :default as the description name.

You can pass all options for the CSV renderer (see : http://ruby-doc.org/stdlib-1.9.2/libdoc/csv/rdoc/CSV.html ), e.g.

```Ruby
 Book.limited(10).to_comma(:style        => :brief,
                           :col_sep      => ';',
                           :force_quotes => true)
```

You can pass the :filename option and have Comma writes the CSV output to this file:

```Ruby
 Book.limited(10).to_comma(:filename => 'books.csv')
```

You also can pass the :write_header option to hide the header line (true is default):

```Ruby
 Book.limited(10).to_comma(:write_headers => false)
```

##Using blocks

For more complex relationships you can pass blocks for calculated values, or related values. Following the previous example here is a comma set using blocks (both with and without labels for your CSV headings):

```Ruby

 class Publisher < ActiveRecord::Base
   # ================
   # = Associations =
   # ================
   has_one  :primary_contact, :class_name => "User" #(basic user with a name)
   has_many :users
 end

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
     publisher { |publisher| publisher.primary_contact.name.to_s.titleize }
     publisher 'Number of publisher users' do |publisher| publisher.users.size end
     isbn :number_10 => 'ISBN-10', :number_13 => 'ISBN-13'
     blurb 'Summary'

   end

 end

```

In the preceding example, the 2 new fields added (both based on the publisher relationship) mean that the following will be added:

*   the first example 'publishers_contact' is loaded straight as a block. The value returned by the lambda is displayed with a header value of 'Publisher'
*   the second example 'total_publishers_users' is sent via a hash and a custom label is set, if used in the first examples method the header would be 'Publisher', but sent as a hash the header is 'Number of publisher users'.

###USING WITH RAILS

When used with Rails (ie. add 'comma' as a gem dependency), Comma automatically adds support for rendering CSV output in your controllers:

```Ruby

 class BooksController < ApplicationController

   def index
     respond_to do |format|
       format.csv { render :csv => Book.limited(50) }
     end
   end

 end

```

You can specify which output format you would like to use by specifying a style parameter or adding any available CSV option:

```Ruby

 class BooksController < ApplicationController

   def index
     respond_to do |format|
       format.csv { render :csv => Book.limited(50), :style => :brief }
     end
   end

 end

```

You can also specify a different file extension ('csv' by default)

```Ruby

class BooksController < ApplicationController

  def index
    respond_to do |format|
      format.csv { render :csv => Book.limited(50), :extension => 'txt' }
    end
  end

end

```

With the Rails renderer you can supply any of the regular parameters that you would use with to_comma such as :filename,
:write_headers, :force_quotes, etc. The parameters just need to be supplied after you specify the collection for the csv as demonstrated
above.

When used with Rails 3.+, Comma also adds support for exporting scopes:

```Ruby

 class Book < ActiveRecord::Base
   scope :recent,
               lambda { { :conditions => ['created_at > ?', 1.month.ago] } }

   # ...
 end

```

Calling the to_comma method on the scope will internally use Rails' find_each method, instantiating only 1,000 ActiveRecord objects at a time:

```Ruby

 Book.recent.to_comma

```

##DEPENDENCIES

If you have any questions or suggestions for Comma, please feel free to contact me at tom@venombytes.com, all feedback welcome!

##TESTING

To run the test suite across multiple gem file sets, we're using [Appraisal](https://github.com/thoughtbot/appraisal), use the following commands :

```Bash

bundle install
bundle exec rake appraisal:install
bundle exec rake appraisal spec

```

When rebuilding for a new rails version, to test across controller and the stack itself, a fake rails app must be generated :

```
rails plugin new rails_app --full --dummy-path=spec/dummy --skip-bundle --skip-gemspec --skip-test-unit --skip-sprockets --skip-javascript --skip-gemfile --skip-git
```

