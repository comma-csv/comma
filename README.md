# Comma

A library to generate comma seperated value (CSV) for Ruby objects like ActiveRecord and Array

[![Gem Version](https://badge.fury.io/rb/comma.svg)](http://badge.fury.io/rb/comma) [![Build Status](https://github.com/comma-csv/comma/actions/workflows/build.yml/badge.svg)](https://github.com/comma-csv/comma/actions/workflows/build.yml) [![Code Climate](https://codeclimate.com/github/comma-csv/comma.svg)](https://codeclimate.com/github/comma-csv/comma)

## Getting Started

### Prerequisites

You need to use ruby 3.0 or later. If you generate CSV from ActiveRecord models, you need to have ActiveRecord 6.0 or later.

### Installing

Comma is distributed as a gem, best installed via Bundler.

Include the gem in your Gemfile:

```ruby
gem 'comma', '~> 4.8.0'
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

## Releasing

Releases are created from git tags. After the version bump PR is merged into `master`, create and push a tag such as `v4.9.0`.

```sh
$ git checkout master
$ git pull --ff-only origin master
$ git tag v4.9.0
$ git push origin v4.9.0
```

Pushing the tag triggers `.github/workflows/release.yml`, which runs the base test suite, builds the gem, publishes it to RubyGems, and creates the matching GitHub Release. The workflow expects the repository secret `RUBYGEMS_API_KEY` to be configured.

## Contributing

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/comma-csv/comma/tags).

## Authors

* Marcus Crafter - Initial work
* Tom Meier - Initial work
* Eito Katagiri

## License

This project is licensed under the MIT License - see the [MIT-LICENSE](https://github.com/comma-csv/comma/blob/master/MIT-LICENSE) file fore details.
