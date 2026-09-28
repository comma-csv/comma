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
