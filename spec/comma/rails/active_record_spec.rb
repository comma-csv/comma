# -*- coding: utf-8 -*-
require 'spec_helper'

if defined? ActiveRecord

  describe Comma, 'generating CSV from an ActiveRecord object' do

    class Person < ActiveRecord::Base
      scope :teenagers, lambda { where(:age => 13..19) }

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

        Person.create(:age => 19, :name => 'John')
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
  end

end
