require File.dirname(__FILE__) + '/../spec_helper'

describe Comma, 'generating CSV from an ActiveRecord object' do
  before(:all) do
    class Person < ActiveRecord::Base
      named_scope :teenagers, :conditions => { :age => 13..19 }
      comma do
        name
        age
      end
    end

    require 'active_record/connection_adapters/abstract_adapter'
    Column = ActiveRecord::ConnectionAdapters::Column
  end

  before do
    Person.stub!(:columns).and_return [Column.new('age', 0, 'integer', false),
                                       Column.new('name', nil, 'string', false) ]
    Person.stub!(:table_exists?).and_return(true)
  end

  describe 'case' do
    before do
      people = [ Person.new(:age => 18, :name => 'Junior') ]
      Person.stub!(:find_every).and_return people
      Person.stub!(:calculate).with(:count, :all, {}).and_return people.size
    end

    it 'should extend ActiveRecord::NamedScope::Scope to add a #to_comma method which will return CSV content for objects within the scope' do
      Person.teenagers.to_comma.should == "Name,Age\nJunior,18\n"
    end

    it 'should find in batches' do
      Person.teenagers.to_comma
    end
  end
end
