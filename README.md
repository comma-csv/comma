# Comma

A library for generating comma-separated values (CSV) from Ruby objects, arrays, and supported ORM collections.

[![Gem Version](https://badge.fury.io/rb/comma.svg)](http://badge.fury.io/rb/comma) [![Build Status](https://github.com/comma-csv/comma/actions/workflows/build.yml/badge.svg)](https://github.com/comma-csv/comma/actions/workflows/build.yml) [![Code Climate](https://codeclimate.com/github/comma-csv/comma.svg)](https://codeclimate.com/github/comma-csv/comma)

## Getting Started

### Prerequisites

You need Ruby 3.1 or later.

For Rails / ActiveRecord integration, this repository is currently tested against ActiveRecord and Rails 7.1 and 7.2 on Ruby 3.1 through 4.0, and Rails 8.0 and 8.1 on Ruby 3.2 through 4.0 (Rails 8.x requires Ruby >= 3.2).

### Installing

Comma is distributed as a gem, best installed via Bundler.

Include the gem in your Gemfile:

```ruby
gem 'comma', '~> 5.0.0'
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

### Dynamic columns

Formats are evaluated separately to produce headers and to produce each row. For CSVs whose columns are configured at runtime, resolve and order the full field-definition list before declaring the `comma` format, and keep that format isolated to the current export so another export cannot redefine it midway through generation.

The following self-contained example uses `Struct` rather than Ruby 3.2+'s
`Data`. It resolves the runtime field list once, attaches the format to a row
class created only for that export, emits headers from `field.label`, and reads
each value from the wrapped user's associated dynamic values via `field.key`:

```ruby
DynamicField = Struct.new(:key, :label)
DynamicValue = Struct.new(:field_key, :value)

class User
  attr_reader :name

  def initialize(name, dynamic_values)
    @name = name
    @dynamic_values_by_field = dynamic_values.to_h do |value|
      [value.field_key, value.value]
    end
  end

  def dynamic_value(field_key)
    @dynamic_values_by_field[field_key]
  end
end

def export_users(users, resolved_fields)
  fields = resolved_fields.to_a
  row_class = Struct.new(:user)

  row_class.comma :export do
    __static_column__ 'Name' do |row|
      row.user.name
    end

    fields.each do |field|
      __static_column__ field.label do |row|
        row.user.dynamic_value(field.key)
      end
    end
  end

  rows = users.map { |user| row_class.new(user) }
  rows.to_comma(:export)
end

users = [
  User.new('Ada', [
    DynamicValue.new(:favorite_color, 'Blue'),
    DynamicValue.new(:support_tier, 'Gold')
  ]),
  User.new('Grace', [
    DynamicValue.new(:favorite_color, 'Green'),
    DynamicValue.new(:support_tier, 'Silver')
  ])
]

fields = [
  DynamicField.new(:favorite_color, 'Favorite color'),
  DynamicField.new(:support_tier, 'Support tier')
]

export_users(users, fields)
# => "Name,Favorite color,Support tier\nAda,Blue,Gold\nGrace,Green,Silver\n"
```

In the example, `field.label` supplies each runtime header and `row.user.dynamic_value(field.key)` reads the matching value from the associated `dynamic_values` records.

When field definitions come from tenant or platform configuration, fetch and order them once for the requested export before the `comma` block is defined. That lets header generation and row generation iterate over the same field list, preserving header/value alignment. Creating `row_class` inside `export_users` also isolates the `:export` format to that one CSV, so a simultaneous export builds its own class instead of overwriting the format being used here.

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
bundle exec appraisal rails7.1.6 bundle exec rspec spec/controllers/users_controller_spec.rb
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
