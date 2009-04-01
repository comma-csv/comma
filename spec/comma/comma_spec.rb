require File.dirname(__FILE__) + '/../spec_helper'

describe Comma do
  
  it 'should extend object to add a comma method' do
    Object.should respond_to(:comma)
  end
  
  it 'should extend object to have a to_comma method' do
    Object.should respond_to(:to_comma)
  end
  
  it 'should extend object to have a to_comma_headers method' do
    Object.should respond_to(:to_comma_headers)
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

  it 'should return an empty string when generating CSV from an empty array' do
    Array.new.to_comma.should == ''
  end
  
end

describe Comma, 'defining CSV descriptions' do
  
  describe 'with an unnamed description' do
    
    before do
      class Foo
        comma do; end
      end        
    end
  
    it 'should name the current description :default if no name has been provided' do
      Foo.comma_formats.should_not be_empty
      Foo.comma_formats[:default].should_not be_nil
    end
  end
  
  describe 'with a named description' do
   
    before do
      class Bar
        comma do; end
        comma :detailed do; end
      end        
    end
    
    it 'should use the provided name to index the comma format' do
      Bar.comma_formats.should_not be_empty
      Bar.comma_formats[:default].should_not be_nil
      Bar.comma_formats[:detailed].should_not be_nil
    end
  end
end

describe Comma, 'to_comma data/headers object extensions' do
  
  describe 'with unnamed descriptions' do
  
    before do
      class Foo
        attr_accessor :content
        comma do; content; end
      
        def initialize(content)
          @content = content
        end
      end
    
      @foo = Foo.new('content')
    end
  
    it 'should return and array of data content, using the :default CSV description if none requested' do
      @foo.to_comma.should == %w(content)
    end

    it 'should return and array of header content, using the :default CSV description if none requested' do
      @foo.to_comma_headers.should == %w(Content)
    end
    
    it 'should return the CSV representation including header and content when called on an array' do
      Array(@foo).to_comma.should == "Content\ncontent\n"
    end

  end
  
  describe 'with named descriptions' do
    
    before do
      class Foo
        attr_accessor :content
        comma :detailed do; content; end
      
        def initialize(content)
          @content = content
        end
      end
    
      @foo = Foo.new('content')
    end
  
    it 'should return and array of data content, using the :default CSV description if none requested' do
      @foo.to_comma(:detailed).should == %w(content)
    end

    it 'should return and array of header content, using the :default CSV description if none requested' do
      @foo.to_comma_headers(:detailed).should == %w(Content)
    end
    
    it 'should return the CSV representation including header and content when called on an array' do
      Array(@foo).to_comma(:detailed).should == "Content\ncontent\n"
    end
    
    it 'should raise an error if the requested description is not avaliable' do
      lambda { @foo.to_comma(:bad) }.should raise_error
      lambda { @foo.to_comma_headers(:bad) }.should raise_error
      lambda { Array(@foo).to_comma(:bad) }.should raise_error
    end
    
  end
  
  describe 'on an object with no comma declaration' do
    
    it 'should raise an error mentioning there is no comma description defined for that class' do
      lambda { 'a string'.to_comma }.should raise_error('No comma format for class String defined for style default')
      lambda { 'a string'.to_comma_headers }.should raise_error('No comma format for class String defined for style default')
    end
    
  end
  
end
