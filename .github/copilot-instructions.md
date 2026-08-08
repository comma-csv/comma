# Copilot instructions for `comma`

## Build, test, and lint commands

This repository is a Ruby gem. Ruby 3.0+ is required, and the CI matrix exercises Ruby 3.0-3.4 against Rails/ActiveRecord appraisals from 6.0 through 7.1.

```sh
# install dependencies for the base Gemfile
bundle install

# install all appraisal Gemfiles used by CI
bundle exec appraisal install

# build the gem
bundle exec rake build

# lint
bundle exec rubocop -P
# or
bundle exec rake rubocop

# base test suite (runs non-Rails specs when framework gems are absent)
bundle exec rspec spec
# or
bundle exec rake spec

# run one example from the base suite
bundle exec rspec spec/comma/comma_spec.rb:205

# run the full multi-gemfile matrix locally
bundle exec appraisal rake spec

# run a single spec file under a specific appraisal
bundle exec appraisal active7.1.3 bundle exec rspec spec/comma/rails/active_record_spec.rb

# CI equivalent for a single matrix entry
BUNDLE_GEMFILE=gemfiles/rails7.1.3.gemfile bundle exec rspec spec/controllers/users_controller_spec.rb
```

## High-level architecture

- `lib/comma/object.rb` adds the core DSL globally via `Object.comma`. Each class stores named format blocks in `comma_formats`, and subclasses inherit a shallow copy of those formats.
- `lib/comma/extractor.rb` is the shared execution engine. It `instance_eval`s a stored format block and collects stringified results. The two concrete extractors split responsibilities:
  - `lib/comma/data_extractor.rb` resolves values from the instance or an associated object and applies optional block-based transformations.
  - `lib/comma/header_extractor.rb` derives headers from the same DSL and can map association columns to the associated model class for humanized labels.
- `lib/comma/generator.rb` is the only place that turns object rows into CSV output. `Array`, `ActiveRecord::Relation`, `Mongoid::Criteria`, and `DataMapper::Collection` each delegate to it from their own extension files.
- `lib/comma.rb` wires framework integrations lazily with `ActiveSupport.on_load`. That file is also where the Rails `render csv:` renderer is registered, so controller behavior is part of the gem's load path rather than test-only glue.
- Integration specs use the miniature app under `spec/rails_app/` plus inline model definitions inside spec files. The base suite still runs without Rails, Mongoid, DataMapper, or ActiveRecord because integration examples are wrapped in `if defined?(...)` guards in the specs.

## Key conventions

- The CSV DSL is method-call driven. Inside a `comma` block, a bare method adds one column, a string argument overrides the header label, and symbol/hash arguments traverse associations. The same block definition drives both headers and row data.
- Style composition uses `__use__ :style_name`, and computed/static columns use `__static_column__`. Preserve those internal DSL entry points when changing extractor behavior.
- Header labels default to `HeaderExtractor.value_humanizer`, which is mutable global state. Specs that override it reset it afterward; follow the same pattern for any future changes.
- `ActiveRecord::Relation#to_comma` intentionally uses `find_each` only for unordered, unlimited relations. If a relation has `limit` or `order`, it falls back to `each`; when Rails is loaded it also emits a warning instead of forcing batched iteration.
- Specs commonly define throwaway classes inline to document DSL behavior instead of introducing fixtures or helper classes. Prefer extending the existing focused examples in `spec/comma/*` unless a change genuinely needs the Rails test app.
