require File.dirname(__FILE__) + '/../spec_helper'

describe Comma do
  
  it 'should extend object to add a comma method' do
    Object.should respond_to(:comma)
  end
  
end

describe Comma, 'generating CSV' do
  
  before do
    @isbn = Isbn.new('123123123', '321321321')
    @book = Book.new('Smalltalk-80', 'Language and Implementation', @isbn)
    
    @books = []
    @books << @book
  end
  
  it 'should extend Array to add a #to_comma method which will return CSV content for objects within the array' do
    @books.to_comma.should == "Title,Description,Issuer,ISBN-10,ISBN-13\nSmalltalk-80,Language and Implementation,ISBN,123123123,321321321\n"
  end
  
end