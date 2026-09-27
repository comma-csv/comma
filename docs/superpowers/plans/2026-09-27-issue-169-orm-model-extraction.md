# Issue #169: Extract ORM Model Classes Out of `describe` Blocks — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the ActiveRecord/Mongoid/DataMapper model classes that are currently defined inline inside RSpec `describe` blocks (`spec/comma/rails/active_record_spec.rb`, `mongoid_spec.rb`, `data_mapper_collection_spec.rb`) into `spec/support/models/`, eliminating the `Lint/ConstantDefinitionInBlock` exclusion in `.rubocop_todo.yml` with zero behavior change.

**Architecture:** Each ORM's model classes move verbatim into their own new file under `spec/support/models/`, each wrapped in the same `if defined?(...)` guard the spec file already uses. `spec/spec_helper.rb` already `Dir.glob`s `spec/support/**/*.rb` (confirmed recursive — picks up nested `models/` files) before requiring the spec files, so the classes are defined at load time exactly as they are today (RSpec evaluates `describe` block bodies immediately, so today's "inside the block" definitions already run at file-load time, not per-example — moving them changes *where* they're defined, not *when*). `before(:all)`/`before`/`it` blocks and all example bodies stay in the spec files untouched.

**Tech Stack:** Ruby, RSpec, RuboCop, ActiveRecord/Mongoid/DataMapper (optional gems, ActiveRecord is the only one actually installed in this repo's appraisal gemfiles — Mongoid and DataMapper have no gemfile in `gemfiles/` or `Appraisals`, so those two spec files never execute in CI; report this as a follow-up finding, do not act on it in this plan).

**Spec:** https://github.com/comma-csv/comma/issues/169 (acceptance criterion: "Reduce at least one entry from `.rubocop_todo.yml`")

## Global Constraints

- No spec behavior changes: same examples, same expectations, same pass/fail outcome.
- Do not rename any class, method, or example description.
- `spec/support/**/*.rb` is auto-required by `spec/spec_helper.rb:38` — new files need no manual `require`.
- Each new model file must open with `# frozen_string_literal: true` (repo convention, see `spec/support/comma_class_helper.rb`).
- Only touch `.rubocop_todo.yml` entries that are provably affected by this move (verified via a real `rubocop` run) — do not loosen unrelated Max/Exclude values.
- ActiveRecord verification runs via `BUNDLE_GEMFILE=gemfiles/active8.1.3.1.gemfile bundle exec rspec spec/comma/rails/active_record_spec.rb` (already installed locally: `bundle check` on that gemfile returns "dependencies are satisfied").

## Review Focus

- Moving `class Person < ActiveRecord::Base` etc. out of the `describe` block must not change load order relative to `before(:all)` (which calls `Person.reset_column_information`, `Picture.create`, etc.) — `before(:all)` hooks only run when examples execute, always after all files finish loading, so order is preserved regardless of which file defines the class. Verified by running the full `active_record_spec.rb` suite, not just a syntax check.
- `class Dog < Animal` and `class Cat < Animal` must stay physically after `class Animal` in the new file (Ruby needs the superclass defined first).
- `DataMapper.finalize` currently runs immediately after the `Person` class body, inside the `describe` block (i.e. at file-load time, before `before(:all)` runs `DataMapper.setup`) — this ordering (finalize before setup) must be preserved exactly when moved, even though it never executes in this repo's CI today.
- The `Style/StringConcatenation` RuboCop exclusion currently lists `spec/comma/rails/active_record_spec.rb` because of `'Dog-' + name` / `'Super-' + name` inside the `Animal`/`Dog` classes — moving those classes moves the offense to the new file, so the `.rubocop_todo.yml` exclude path must move with it, not just get deleted.
- After deleting ~100 lines from each spec file's outer `describe` block, the existing `# rubocop:disable Metrics/BlockLength` inline comments on those `describe` lines may become unused, which RuboCop's `Lint/RedundantCopDisableDirective` (enabled by default) will flag as a new offense — must run RuboCop after each file edit and remove the comment if it's now redundant.

---

## Task 1: Extract ActiveRecord models

**Files:**
- Create: `spec/support/models/active_record_models.rb`
- Modify: `spec/comma/rails/active_record_spec.rb` (currently 202 lines)

**Interfaces:**
- Produces: top-level constants `Picture`, `Person`, `Job`, `PersonFormatter`, `Animal`, `Dog`, `Cat`, available to `active_record_spec.rb`'s examples exactly as before.

- [ ] **Step 1: Record the baseline (before touching anything)**

Run:
```bash
BUNDLE_GEMFILE=gemfiles/active8.1.3.1.gemfile bundle exec rspec spec/comma/rails/active_record_spec.rb
```
Expected: `11 examples, 0 failures` (this is the known-good baseline to diff against after the refactor).

- [ ] **Step 2: Create `spec/support/models/active_record_models.rb`**

```ruby
# frozen_string_literal: true

# ActiveRecord model classes for spec/comma/rails/active_record_spec.rb.
# Defined here (top-level, outside any RSpec block) instead of inside the
# describe block so they satisfy RuboCop's Lint/ConstantDefinitionInBlock
# while still resolving real ActiveRecord table-name/STI conventions.
if defined?(ActiveRecord)
  class Picture < ActiveRecord::Base
    belongs_to :imageable, polymorphic: true

    comma :pr_83 do
      imageable name: 'Picture'
    end
  end

  class Person < ActiveRecord::Base
    scope(:teenagers, -> { where(age: 13..19) })

    comma do
      name
      age
    end

    has_one :job

    comma :issue_75 do
      job :title
    end

    has_many :pictures, as: :imageable
  end

  class Job < ActiveRecord::Base
    belongs_to :person

    comma do
      person_formatter name: 'Name'
    end

    def person_formatter
      @person_formatter ||= PersonFormatter.new(person)
    end
  end

  class PersonFormatter
    def initialize(persor)
      @person = persor
    end

    def name
      @person.name
    end
  end

  class Animal < ActiveRecord::Base
    comma do
      name 'Name' do |name|
        'Super-' + name
      end
    end

    comma :with_type do
      name
      type
    end
  end

  class Dog < Animal
    comma do
      name 'Name' do |name|
        'Dog-' + name
      end
    end
  end

  class Cat < Animal
  end
end
```

- [ ] **Step 3: Rewrite `spec/comma/rails/active_record_spec.rb`, removing the moved class bodies**

Replace the full file with:

```ruby
# frozen_string_literal: true

require 'spec_helper'

if defined? ActiveRecord

  describe Comma, 'generating CSV from an ActiveRecord object' do
    before(:all) do
      # Setup AR model in memory
      ActiveRecord::Base.connection.create_table :pictures, force: true do |table|
        table.column :name, :string
        table.column :imageable_id, :integer
        table.column :imageable_type, :string
      end

      ActiveRecord::Base.connection.create_table :people, force: true do |table|
        table.column :name, :string
        table.column :age, :integer
      end
      Person.reset_column_information

      ActiveRecord::Base.connection.create_table :jobs, force: true do |table|
        table.column :person_id, :integer
        table.column :title, :string
      end
      Job.reset_column_information

      @person = Person.new(age: 18, name: 'Junior')
      @person.build_job(title: 'Nice job')
      @person.save!
      Picture.create(name: 'photo.jpg', imageable_id: @person.id, imageable_type: 'Person')
    end

    describe '#to_comma on scopes' do
      it 'should extend ActiveRecord::NamedScope::Scope to add a #to_comma method which will return CSV content for objects within the scope' do # rubocop:disable Layout/LineLength
        expect(Person.teenagers.to_comma).to eq "Name,Age\nJunior,18\n"
      end

      it 'should find in batches' do
        scope = Person.teenagers
        expect(scope).to receive(:find_each).and_yield @person
        scope.to_comma
      end

      it 'should fall back to iterating with each when scope has limit clause' do
        scope = Person.limit(1)
        expect(scope).to receive(:each).and_yield @person
        scope.to_comma
      end

      it 'should fall back to iterating with each when scope has order clause' do
        scope = Person.order(:age)
        expect(scope).to receive(:each).and_yield @person
        scope.to_comma
      end
    end

    describe 'with custom value_humanizer' do
      before do
        Comma::HeaderExtractor.value_humanizer =
          lambda do |value, model_class|
            if model_class.respond_to?(:human_attribute_name)
              model_class.human_attribute_name(value)
            else
              value.is_a?(String) ? value : value.to_s.humanize
            end
          end

        I18n.config.backend.store_translations(:ja, activerecord: { attributes: { person: { age: '年齢', name: '名前' } } })
        @original_locale = I18n.locale
        I18n.locale = :ja
      end

      after do
        I18n.locale = @original_locale

        Comma::HeaderExtractor.value_humanizer =
          Comma::HeaderExtractor::DEFAULT_VALUE_HUMANIZER
      end

      it 'should i18n-ize header values' do
        expect(Person.teenagers.to_comma).to match(/^名前,年齢/)
      end
    end

    describe 'github issue 75' do
      it 'should find association' do
        expect { Person.all.to_comma(:issue_75) }.not_to raise_error
      end
    end

    describe 'with accessor' do
      it 'should not raise exception' do
        expect(Job.all.to_comma).to eq("Name\nJunior\n")
      end
    end

    describe 'github pull-request 83' do
      it 'should not raise NameError' do
        expect { Picture.all.to_comma(:pr_83) }.not_to raise_error
      end
    end
  end

  describe Comma, 'generating CSV from an ActiveRecord object using Single Table Inheritance' do
    before(:all) do
      # Setup AR model in memory
      ActiveRecord::Base.connection.create_table :animals, force: true do |table|
        table.column :name, :string
        table.column :type, :string
      end

      @dog = Dog.new(name: 'Rex')
      @dog.save!
      @cat = Cat.new(name: 'Kitty')
      @cat.save!
    end

    it 'should return and array of data content, as defined in comma block in child class' do
      expect(@dog.to_comma).to eq %w[Dog-Rex]
    end

    it 'should return and array of data content, as defined in comma block in super class, if not present in child' do
      expect(@cat.to_comma).to eq %w[Super-Kitty]
    end

    it 'should call definion in parent class' do
      expect { @dog.to_comma(:with_type) }.not_to raise_error
    end
  end
end
```

Note: both `describe Comma, '...'` lines drop their `# rubocop:disable Metrics/BlockLength` comment here — verify in Step 5 whether that's correct (block is now much shorter) and restore the comment on whichever `describe` still needs it if RuboCop's `Metrics/BlockLength` still fires.

- [ ] **Step 4: Re-run the spec suite and diff against baseline**

Run:
```bash
BUNDLE_GEMFILE=gemfiles/active8.1.3.1.gemfile bundle exec rspec spec/comma/rails/active_record_spec.rb
```
Expected: `11 examples, 0 failures` — identical to Step 1's baseline. If anything fails, stop and debug before proceeding (do not move to Task 2 with a red test).

- [ ] **Step 5: Run RuboCop on the two touched files**

Run:
```bash
bundle exec rubocop spec/comma/rails/active_record_spec.rb spec/support/models/active_record_models.rb
```
Expected outcomes to reconcile by hand (don't auto-gen-config over the whole todo file):
- `Lint/ConstantDefinitionInBlock` should no longer fire on `active_record_spec.rb` (classes are no longer inside a block).
- `Metrics/BlockLength` may or may not still fire on the two `describe` blocks — if it does, put back `# rubocop:disable Metrics/BlockLength` / `# rubocop:enable Metrics/BlockLength` on that specific `describe` line; if it doesn't, leave the comment removed (do not leave a dangling disable comment — `Lint/RedundantCopDisableDirective` will flag it).
- `Style/StringConcatenation` will likely now fire on `active_record_models.rb` (the `'Dog-' + name` / `'Super-' + name` lines) instead of on the spec file — this is a relocation, not a new offense; leave the `.rubocop_todo.yml` fix for Task 4.

Do not edit `.rubocop_todo.yml` in this task — Task 4 reconciles it once all three ORMs have been extracted, so the diff is reviewed in one place.

- [ ] **Step 6: Commit**

```bash
git add spec/support/models/active_record_models.rb spec/comma/rails/active_record_spec.rb
git commit -m "test: extract ActiveRecord spec models out of describe block"
```

---

## Task 2: Extract Mongoid model

**Files:**
- Create: `spec/support/models/mongoid_models.rb`
- Modify: `spec/comma/rails/mongoid_spec.rb` (currently 41 lines)

**Interfaces:**
- Produces: top-level constant `Person` (Mongoid document), available to `mongoid_spec.rb`'s examples exactly as before.
- Note: this `Person` class is guarded by `if defined?(Mongoid)` and never actually loads in this repo (no `mongoid` gem in any `Gemfile`/`gemfiles/*.gemfile`/`Appraisals`) — verification for this task is therefore limited to "file loads without raising" and "RuboCop is clean," not a green example run.

- [ ] **Step 1: Create `spec/support/models/mongoid_models.rb`**

```ruby
# frozen_string_literal: true

# Mongoid model class for spec/comma/rails/mongoid_spec.rb.
# Defined here (top-level, outside any RSpec block) instead of inside the
# describe block so it satisfies RuboCop's Lint/ConstantDefinitionInBlock.
if defined?(Mongoid)
  class Person
    include Mongoid::Document

    field :name, type: String
    field :age, type: Integer

    scope :teenagers, between(age: 13..19)

    comma do
      name
      age
    end
  end
end
```

- [ ] **Step 2: Rewrite `spec/comma/rails/mongoid_spec.rb`**

```ruby
# frozen_string_literal: true

require 'spec_helper'

if defined? Mongoid

  describe Comma, 'generating CSV from an Mongoid object' do
    after(:all) do
      Mongoid.purge!
    end

    describe 'case' do
      before do
        @person = Person.new(age: 18, name: 'Junior')
        @person.save
      end

      it 'should extend ActiveRecord::NamedScope::Scope to add a #to_comma method which will return CSV content for objects within the scope' do # rubocop:disable Layout/LineLength
        Person.teenagers.to_comma.should == "Name,Age\nJunior,18\n"
      end

      it 'should find in batches' do
        Person.teenagers.to_comma
      end
    end
  end
end
```

- [ ] **Step 3: Confirm the guarded file loads cleanly and the suite is still all-green**

Run:
```bash
bundle exec rspec spec/ 2>&1 | tail -5
```
Expected: same total example/failure counts as before this task started (Mongoid is undefined in every configured gemfile, so `mongoid_spec.rb`'s `describe` block — and the new `mongoid_models.rb` guard — both no-op; this run must not raise `LoadError`/`NameError` and must not change the example count).

- [ ] **Step 4: Run RuboCop on the two touched files**

Run:
```bash
bundle exec rubocop spec/comma/rails/mongoid_spec.rb spec/support/models/mongoid_models.rb
```
Expected: `Lint/ConstantDefinitionInBlock` no longer fires on `mongoid_spec.rb`. Leave `.rubocop_todo.yml` untouched here — reconciled in Task 4.

- [ ] **Step 5: Commit**

```bash
git add spec/support/models/mongoid_models.rb spec/comma/rails/mongoid_spec.rb
git commit -m "test: extract Mongoid spec model out of describe block"
```

---

## Task 3: Extract DataMapper model

**Files:**
- Create: `spec/support/models/data_mapper_models.rb`
- Modify: `spec/comma/rails/data_mapper_collection_spec.rb` (currently 49 lines)

**Interfaces:**
- Produces: top-level constant `Person` (DataMapper resource), available to `data_mapper_collection_spec.rb`'s examples exactly as before.
- Note: like Task 2, this is guarded by `if defined?(DataMapper)` and never loads in this repo's CI today — same limited verification scope applies.

- [ ] **Step 1: Create `spec/support/models/data_mapper_models.rb`**

```ruby
# frozen_string_literal: true

# DataMapper model class for spec/comma/rails/data_mapper_collection_spec.rb.
# Defined here (top-level, outside any RSpec block) instead of inside the
# describe block so it satisfies RuboCop's Lint/ConstantDefinitionInBlock.
# DataMapper.finalize must stay right after the class body, before
# DataMapper.setup runs in the spec's before(:all) — same ordering the
# inline version relied on.
if defined?(DataMapper)
  class Person
    include DataMapper::Resource

    property :id, Serial
    property :name, String
    property :age, Integer

    def self.teenagers
      all(:age.gte => 13) & all(:age.lte => 19)
    end

    comma do
      name
      age
    end
  end

  DataMapper.finalize
end
```

- [ ] **Step 2: Rewrite `spec/comma/rails/data_mapper_collection_spec.rb`**

```ruby
# frozen_string_literal: true

require 'spec_helper'

if defined? DataMapper

  describe Comma, 'generating CSV from an DataMapper object' do
    before(:all) do
      DataMapper.setup(:default, 'sqlite::memory:')
      DataMapper.auto_migrate!
    end

    after(:all) do
    end

    describe 'case' do
      before do
        @person = Person.new(age: 18, name: 'Junior')
        @person.save
      end

      it 'should extend scope to add a #to_comma method which will return CSV content for objects within the scope' do
        Person.teenagers.to_comma.should == "Name,Age\nJunior,18\n"
      end

      it 'should find in batches' do
        Person.teenagers.to_comma
      end
    end
  end
end
```

- [ ] **Step 3: Confirm the guarded file loads cleanly and the suite is still all-green**

Run:
```bash
bundle exec rspec spec/ 2>&1 | tail -5
```
Expected: same total example/failure counts as before this task started (DataMapper is undefined in every configured gemfile, so this is a no-op guard check, same rationale as Task 2 Step 3).

- [ ] **Step 4: Run RuboCop on the two touched files**

Run:
```bash
bundle exec rubocop spec/comma/rails/data_mapper_collection_spec.rb spec/support/models/data_mapper_models.rb
```
Expected: `Lint/ConstantDefinitionInBlock` no longer fires on `data_mapper_collection_spec.rb`. Leave `.rubocop_todo.yml` untouched here — reconciled in Task 4.

- [ ] **Step 5: Commit**

```bash
git add spec/support/models/data_mapper_models.rb spec/comma/rails/data_mapper_collection_spec.rb
git commit -m "test: extract DataMapper spec model out of describe block"
```

---

## Task 4: Reconcile `.rubocop_todo.yml` and run full verification

**Files:**
- Modify: `.rubocop_todo.yml`

**Interfaces:**
- Consumes: the RuboCop output from Tasks 1-3's Step 5/4 runs (re-run fresh here across the whole repo, since todo-file changes affect global cop behavior).

- [ ] **Step 1: Run RuboCop across the whole repo with the current (unmodified) `.rubocop_todo.yml`**

Run:
```bash
bundle exec rubocop
```
Record every offense reported for `spec/comma/rails/*.rb` and `spec/support/models/*.rb` — these are the only files this plan touched, so any offense on them is either (a) `Lint/ConstantDefinitionInBlock` no longer firing (good — means we can delete that block), (b) `Style/StringConcatenation` now firing on `active_record_models.rb` instead of `active_record_spec.rb` (expected relocation), or (c) an unexpected new offense (stop and investigate — do not paper over with a new exclusion without understanding why).

- [ ] **Step 2: Edit `.rubocop_todo.yml`**

Delete the entire `Lint/ConstantDefinitionInBlock` block:
```yaml
# Offense count: 17
# Configuration parameters: AllowedMethods.
# AllowedMethods: enums
Lint/ConstantDefinitionInBlock:
  Exclude:
    - 'spec/comma/rails/active_record_spec.rb'
    - 'spec/comma/rails/data_mapper_collection_spec.rb'
    - 'spec/comma/rails/mongoid_spec.rb'
```

In the `Style/StringConcatenation` block, replace the relocated path (keep the comment's offense count as-is unless Step 1 showed a different count — update the number only if it changed):
```yaml
Style/StringConcatenation:
  Exclude:
    - 'spec/comma/comma_spec.rb'
    - 'spec/comma/rails/active_record_spec.rb'
    - 'spec/spec_helper.rb'
```
becomes:
```yaml
Style/StringConcatenation:
  Exclude:
    - 'spec/comma/comma_spec.rb'
    - 'spec/support/models/active_record_models.rb'
    - 'spec/spec_helper.rb'
```
(Only make this edit if Step 1 actually showed `Style/StringConcatenation` firing on `active_record_models.rb` — if RuboCop is clean there, e.g. because the `'Dog-' + name` construct doesn't trip that cop in isolation, leave the exclude list untouched and just remove the file path without adding a replacement.)

- [ ] **Step 3: Re-run RuboCop across the whole repo**

Run:
```bash
bundle exec rubocop
```
Expected: no offenses (exit 0). If anything unexpected remains, fix the actual code (or the todo entry, following the same relocate-don't-loosen rule) until this is clean.

- [ ] **Step 4: Run the full test suite**

Run:
```bash
bundle exec rspec
BUNDLE_GEMFILE=gemfiles/active8.1.3.1.gemfile bundle exec rspec
```
Expected: 0 failures on both invocations, and the ActiveRecord run's example count matches Task 1 Step 1's baseline for `active_record_spec.rb` (11 examples in that file, same total elsewhere).

- [ ] **Step 5: Update the issue's acceptance-criteria checklist context (for the PR description, not a file edit)**

No file changes here — just confirm before writing the PR description that all of these now hold, per issue #169:
- [x] At least one support helper added and used in 2+ spec files (already true from PR #180: `define_comma_class`/`expect_csv` used in 4 files)
- [x] No spec behavior changes (verified in Step 4)
- [x] Reduced at least one entry from `.rubocop_todo.yml` (`Lint/ConstantDefinitionInBlock` fully removed)

- [ ] **Step 6: Commit**

```bash
git add .rubocop_todo.yml
git commit -m "chore: drop Lint/ConstantDefinitionInBlock rubocop_todo exclusion"
```
