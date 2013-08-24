# -*- coding: utf-8 -*-
require 'spec_helper'

# comma do
#   name 'Title'
#   description
#
#   isbn :number_10 => 'ISBN-10', :number_13 => 'ISBN-13'
# end

describe Comma::DataExtractor do

  before do
    @isbn = Isbn.new('123123123', '321321321')
    @book = Book.new('Smalltalk-80', 'Language and Implementation', @isbn)

    @data = @book.to_comma
  end

  describe 'when no parameters are provided' do

    it 'should use the string value returned by sending the method name on the object' do
      @data.should include('Language and Implementation')
    end
  end

  describe 'when given a string description as a parameter' do

    it 'should use the string value returned by sending the method name on the object' do
      @data.should include('Smalltalk-80')
    end
  end

  describe 'when an hash is passed as a parameter' do

    describe 'with a string value' do

      it 'should use the string value, returned by sending the hash key to the object' do
        @data.should include('123123123')
        @data.should include('321321321')
      end

      it 'should not fail when an associated object is nil' do
        lambda { Book.new('Smalltalk-80', 'Language and Implementation', nil).to_comma }.should_not raise_error
      end
    end
  end

end

describe Comma::DataExtractor, 'id attribute' do
  before do
    @data = Class.new(Struct.new(:id)) do
      comma do
        id 'ID' do |id| '42' end
      end
    end.new(1).to_comma
  end

  it 'id attribute should yield block' do
    @data.should include('42')
  end
end

describe Comma::DataExtractor, 'with static column method' do
  before do
    @data = Class.new(Struct.new(:id, :name)) do
      comma do
        __static_column__
        __static_column__ 'STATIC'
        __static_column__ 'STATIC' do '' end
        __static_column__ 'STATIC' do |o| o.name end
      end
    end.new(1, 'John Doe').to_comma
  end

  it 'should extract headers' do
    @data.should eq([nil, nil, '', 'John Doe'])
  end
end

describe Comma::DataExtractor, 'nil value' do
  before do
    @data = Class.new(Struct.new(:id, :name)) do
      comma do
        name
        name 'Name'
        name 'Name' do |name| nil end
      end
    end.new(1, nil).to_comma
  end

  it 'should extract nil' do
    @data.should eq([nil, nil, nil])
  end
end
