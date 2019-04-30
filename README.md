# Comma

A library to generate comma seperated value (CSV) for Ruby objects like ActiveRecord and Array

[![Gem Version](https://badge.fury.io/rb/comma.png)](http://badge.fury.io/rb/comma) [![Build Status](https://travis-ci.org/comma-csv/comma.png?branch=master)](https://travis-ci.org/comma-csv/comma) [![Code Climate](https://codeclimate.com/github/comma-csv/comma.png)](https://codeclimate.com/github/comma-csv/comma)

## Getting Started

### Prerequisites

You need to use ruby 2.3 or later. If you generate CSV from ActiveRecord models, you need to have ActiveRecord 4.2 or later.

### Installing

Comma is distributed as a gem, best installed via Bundler.

Include the gem in your Gemfile:

```ruby
gem 'comma', '~> 4.3.2'
```

Or, if you want to live life on the edge, you can get master from the main comma repository:

```ruby
gem 'comma',  git: 'git://github.com/comma-csv/comma.git'
```

Then, run `bundle install`.

### Usage

See [this page](https://github.com/comma-csv/comma/wiki) for usages.

## Running the tests

To run the test suite across multiple gem file sets, we're using [Appraisal](https://github.com/thoughtbot/appraisal), use the following commands:

```sh
$ bundle exec appraisal install
$ bundle exec appraisal rake spec

```

## Contributing

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/comma-csv/comma/tags).

## Authors

* Marcus Crafter - Initial work
* Tom Meier - Initial work
* Eito Katagiri

## License

This project is licensed under the MIT License - see the [MIT-LICENSE](https://github.com/comma-csv/comma/blob/master/MIT-LICENSE) file fore details.
