require File.dirname(__FILE__) + '/../spec_helper'

# comma do
#   name 'Title'
#   description
#   
#   isbn :number_10 => 'ISBN-10', :number_13 => 'ISBN-13'
# end

describe Comma::HeaderExtractor do
  
  before do
    @isbn = Isbn.new('123123123', '321321321')
    @book = Book.new('Smalltalk-80', 'Language and Implementation', @isbn)
    
    @headers = @book.to_comma_headers
  end
  
  describe 'when no parameters are provided' do
    
    it 'should use the method name as the header name, humanized' do
      @headers.should include('Description')
    end
  end
  
  describe 'when given a string description as a parameter' do
    
    it 'should use the string value, unmodified' do
      @headers.should include('Title')
    end
  end
  
  describe 'when an hash is passed as a parameter' do
    
    describe 'with a string value' do
      
      it 'should use the string value, unmodified' do
        @headers.should include('ISBN-10')
      end
    end
    
    describe 'with a non-string value' do
      
      it 'should use the non string value converted to a string, humanized' do
        @headers.should include('Issuer')
      end
    end
    
  end
    
end

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