require 'spec_helper'

describe Comma, 'generating CSV from an ActiveRecord object' do

  class Person < ActiveRecord::Base
    scope :teenagers, lambda { {:conditions => { :age => 13..19 }} }

    comma do
      name
      age
    end

  end

  before(:all) do
    #Setup AR model in memory
    ActiveRecord::Base.connection.create_table :people, :force => true do |table|
      table.column :name, :string
      table.column :age, :integer
    end
    Person.reset_column_information
  end

  describe "case" do
    before do
      @person = Person.new(:age => 18, :name => 'Junior')
      @person.save!
    end

    it 'should extend ActiveRecord::NamedScope::Scope to add a #to_comma method which will return CSV content for objects within the scope' do
      Person.teenagers.to_comma.should == "Name,Age\nJunior,18\n"
    end

    it 'should find in batches' do
      Person.teenagers.to_comma
    end
  end
end
