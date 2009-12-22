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

  it "should change the style when specified" do
    @books.to_comma(:brief).should == "Name,Description\nSmalltalk-80,Language and Implementation\n"
  end

  describe 'with :filename specified' do
    after{ File.delete('comma.csv') }

    it "should write to the file" do
      @books.to_comma(:filename => 'comma.csv')
      File.read('comma.csv').should == "Title,Description,Issuer,ISBN-10,ISBN-13\nSmalltalk-80,Language and Implementation,ISBN,123123123,321321321\n"
    end

    it "should accept FasterCSV options" do
      @books.to_comma(:filename => 'comma.csv', :col_sep => ';', :force_quotes => true)
      File.read('comma.csv').should == "\"Title\";\"Description\";\"Issuer\";\"ISBN-10\";\"ISBN-13\"\n\"Smalltalk-80\";\"Language and Implementation\";\"ISBN\";\"123123123\";\"321321321\"\n"
    end

  end

  describe "with FasterCSV options" do
    it "should not change when options are empty" do
      @books.to_comma({}).should == "Title,Description,Issuer,ISBN-10,ISBN-13\nSmalltalk-80,Language and Implementation,ISBN,123123123,321321321\n"
    end

    it 'should accept the options in #to_comma and generate the appropriate CSV' do
      @books.to_comma(:col_sep => ';', :force_quotes => true).should == "\"Title\";\"Description\";\"Issuer\";\"ISBN-10\";\"ISBN-13\"\n\"Smalltalk-80\";\"Language and Implementation\";\"ISBN\";\"123123123\";\"321321321\"\n"
    end

    it "should change the style when specified" do
      @books.to_comma(:style => :brief, :col_sep => ';', :force_quotes => true).should == "\"Name\";\"Description\"\n\"Smalltalk-80\";\"Language and Implementation\"\n"
    end
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

  describe 'with block' do
    before do
      class Foo
        attr_accessor :content, :created_at, :updated_at
        comma do
          time_to_s = lambda { |i| i && i.to_s(:db) }
          content
          content('Truncated Content') {|i| i && i.length > 10 ? i[0..10] : '---' }
          created_at &time_to_s
          updated_at &time_to_s
        end
        
        def initialize(content, created_at = Time.now, updated_at = Time.now)
          @content = content
          @created_at = created_at
          @updated_at = updated_at
        end
      end
      
      @time = Time.now
      @content = 'content ' * 5
      @foo = Foo.new @content, @time, @time
    end
    
    it 'should return yielded values by block' do
      header, foo = Array(@foo).to_comma.split("\n")
      foo.should == [@content, @content[0..10], @time.to_s(:db), @time.to_s(:db)].join(',')
    end
    
  end
  
  describe 'on an object with no comma declaration' do
    
    it 'should raise an error mentioning there is no comma description defined for that class' do
      lambda { 'a string'.to_comma }.should raise_error('No comma format for class String defined for style default')
      lambda { 'a string'.to_comma_headers }.should raise_error('No comma format for class String defined for style default')
    end
    
  end
  
end
