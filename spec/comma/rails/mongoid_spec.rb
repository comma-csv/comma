# frozen_string_literal: true

require 'spec_helper'

if defined? Mongoid

  describe Comma, 'generating CSV from an Mongoid object' do
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

    after(:all) do
      Mongoid.purge!
    end

    describe 'case' do
      before do
        @person = Person.new(age: 18, name: 'Junior')
        @person.save
      end

      it 'should extend ActiveRecord::NamedScope::Scope to add a #to_comma method which will return CSV content for objects within the scope' do # rubocop:disable Metrics/LineLength
        Person.teenagers.to_comma.should == "Name,Age\nJunior,18\n"
      end

      it 'should find in batches' do
        Person.teenagers.to_comma
      end
    end
  end
end
