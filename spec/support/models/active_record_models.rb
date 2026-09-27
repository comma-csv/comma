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
