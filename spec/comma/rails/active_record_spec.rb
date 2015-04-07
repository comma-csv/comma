# -*- coding: utf-8 -*-
require 'spec_helper'

if defined? ActiveRecord

  describe Comma, 'generating CSV from an ActiveRecord object' do

    class Picture < ActiveRecord::Base
      belongs_to :imageable, :polymorphic => true

      comma :pr_83 do
        imageable :name => 'Picture'
      end
    end

    class Person < ActiveRecord::Base
      scope :teenagers, lambda { where(:age => 13..19) }

      comma do
        name
        age
      end

      has_one :job

      comma :issue_75 do
        job :title
      end

      has_many :pictures, :as => :imageable
    end

    class Job < ActiveRecord::Base
      belongs_to :person

      comma do
        person_formatter :name => 'Name'
      end

      def person_formatter
        @person_formatter ||= PersonFormatter.new(self.person)
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

    before(:all) do
      #Setup AR model in memory
      ActiveRecord::Base.connection.create_table :pictures, :force => true do |table|
        table.column :name, :string
        table.column :imageable_id, :integer
        table.column :imageable_type, :string
      end

      ActiveRecord::Base.connection.create_table :people, :force => true do |table|
        table.column :name, :string
        table.column :age, :integer
      end
      Person.reset_column_information

      ActiveRecord::Base.connection.create_table :jobs, :force => true do |table|
        table.column :person_id, :integer
        table.column :title, :string
      end
      Job.reset_column_information

      @person = Person.new(:age => 18, :name => 'Junior')
      @person.build_job(:title => 'Nice job')
      @person.save!
      Picture.create(:name => 'photo.jpg', :imageable_id => @person.id, :imageable_type => 'Person')
    end

    describe "#to_comma on scopes" do
      it 'should extend ActiveRecord::NamedScope::Scope to add a #to_comma method which will return CSV content for objects within the scope' do
        Person.teenagers.to_comma.should == "Name,Age\nJunior,18\n"
      end

      it 'should find in batches' do
        scope = Person.teenagers
        scope.should_receive(:find_each).and_yield @person
        scope.to_comma
      end

      it 'should fall back to iterating with each when scope has limit clause' do
        scope = Person.limit(1)
        scope.should_receive(:each).and_yield @person
        scope.to_comma
      end

      it 'should fall back to iterating with each when scope has order clause' do
        scope = Person.order(:age)
        scope.should_receive(:each).and_yield @person
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

        I18n.config.backend.store_translations(:ja, {:activerecord => {:attributes => {:person => {:age => '年齢', :name => '名前'}}}})
        @original_locale = I18n.locale
        I18n.locale = :ja
      end

      after do
        I18n.locale = @original_locale

        Comma::HeaderExtractor.value_humanizer =
          Comma::HeaderExtractor::DEFAULT_VALUE_HUMANIZER
      end

      it 'should i18n-ize header values' do
        Person.teenagers.to_comma.should match(/^名前,年齢/)
      end
    end

    describe 'github issue 75' do
      it 'should find association' do
        lambda { Person.all.to_comma(:issue_75) }.should_not raise_error
      end
    end

    describe 'with accessor' do
      it 'should not raise exception' do
        Job.all.to_comma.should eq("Name\nJunior\n")
      end
    end

    describe 'github pull-request 83' do
      it 'should not raise NameError' do
        lambda { Picture.all.to_comma(:pr_83) }.should_not raise_exception(NameError)
      end
    end
  end

  describe Comma, 'generating CSV from an ActiveRecord object using Single Table Inheritance' do
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

    before(:all) do
      #Setup AR model in memory
      ActiveRecord::Base.connection.create_table :animals, :force => true do |table|
        table.column :name, :string
        table.column :type, :string
      end

      @dog = Dog.new(:name => 'Rex')
      @dog.save!
      @cat = Cat.new(:name => 'Kitty')
      @cat.save!
    end

    it 'should return and array of data content, as defined in comma block in child class' do
      @dog.to_comma.should == %w(Dog-Rex)
    end

    #FIXME: this one is failing - the comma block from Dog is executed instead of the one from the super class
    it 'should return and array of data content, as defined in comma block in super class, if not present in child' do
      @cat.to_comma.should == %w(Super-Kitty)
    end

    it 'should call definion in parent class' do
      lambda { @dog.to_comma(:with_type) }.should_not raise_error
    end
  end
end
