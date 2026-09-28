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
