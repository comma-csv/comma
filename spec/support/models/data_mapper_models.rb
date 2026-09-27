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
