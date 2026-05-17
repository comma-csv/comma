# Comma

A library for generating comma-separated values (CSV) from Ruby objects, arrays, and supported ORM collections.

[![Gem Version](https://badge.fury.io/rb/comma.svg)](http://badge.fury.io/rb/comma) [![Build Status](https://github.com/comma-csv/comma/actions/workflows/build.yml/badge.svg)](https://github.com/comma-csv/comma/actions/workflows/build.yml) [![Code Climate](https://codeclimate.com/github/comma-csv/comma.svg)](https://codeclimate.com/github/comma-csv/comma)

## Getting Started

### Prerequisites

You need Ruby 3.0 or later.

For Rails / ActiveRecord integration, this repository is currently tested against ActiveRecord and Rails 6.0 through 7.1 on Ruby 3.0 through 3.4.

### Installing

Comma is distributed as a gem, best installed via Bundler.

Include the gem in your Gemfile:

```ruby
gem 'comma', '~> 4.9.0'
```

Or, if you want to live life on the edge, you can get master from the main comma repository:

```ruby
gem 'comma', git: 'https://github.com/comma-csv/comma.git'
```

Then, run `bundle install`.

### Usage

Define a CSV format on your object with `comma`. Calling `to_comma` on a single object returns the row values, while calling it on an array or supported collection generates CSV output:

```ruby
class User
  attr_reader :first_name, :last_name

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end

  comma do
    first_name
    last_name
    full_name 'Name'
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end
end

user = User.new('Ada', 'Lovelace')
user.to_comma
# => ["Ada", "Lovelace", "Ada Lovelace"]

users = [User.new('Ada', 'Lovelace'), User.new('Grace', 'Hopper')]
users.to_comma
# => "First name,Last name,Name\nAda,Lovelace,Ada Lovelace\nGrace,Hopper,Grace Hopper\n"
```

You can also define named styles and select them when generating CSV:

```ruby
class User
  comma :short do
    first_name
    last_name
  end
end

users.to_comma(:short)
```

In Rails controllers, requiring the gem registers `render csv:` support:

```ruby
def index
  render csv: User.all
end
```

See the [wiki](https://github.com/comma-csv/comma/wiki) for more usage examples.

## Running the tests

Install dependencies:

```sh
bundle install
bundle exec appraisal install
```

Run the default test suite and linter:

```sh
bundle exec rspec spec
bundle exec rubocop -P
```

Run a single example:

```sh
bundle exec rspec spec/comma/comma_spec.rb:205
```

To run the test suite across the Rails / ActiveRecord gemfile matrix, this repository uses [Appraisal](https://github.com/thoughtbot/appraisal):

```sh
bundle exec appraisal rake spec
```

You can also run a specific spec under one appraisal:

```sh
bundle exec appraisal rails7.1.3 bundle exec rspec spec/controllers/users_controller_spec.rb
```

## Contributing

Please make sure `bundle exec rspec spec`, `bundle exec rubocop -P`, and any relevant `bundle exec appraisal ...` commands pass before opening a pull request.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/comma-csv/comma/tags).

## Authors

* Marcus Crafter - Initial work
* Tom Meier - Initial work
* Eito Katagiri

## License

This project is licensed under the MIT License - see the [MIT-LICENSE](https://github.com/comma-csv/comma/blob/master/MIT-LICENSE) file for details.
