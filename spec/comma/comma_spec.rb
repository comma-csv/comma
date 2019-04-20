# frozen_string_literal: true

require File.dirname(__FILE__) + '/../spec_helper'

describe Comma do
  it 'should extend object to add a comma method' do
    expect(Object).to respond_to(:comma)
  end

  it 'should extend object to have a to_comma method' do
    expect(Object).to respond_to(:to_comma)
  end

  it 'should extend object to have a to_comma_headers method' do
    expect(Object).to respond_to(:to_comma_headers)
  end

  describe '.to_comma_header' do
    it 'should not crash (#94)' do
      klass = Class.new
      klass.instance_eval do
        attr_accessor :name

        comma :brief do
          name
        end
      end
      expect { klass.to_comma_headers(:brief) }.to_not raise_error
    end
  end
end

describe Comma, 'generating CSV' do # rubocop:disable Metrics/BlockLength
  before do
    @isbn = Isbn.new('123123123', '321321321')
    @book = Book.new('Smalltalk-80', 'Language and Implementation', @isbn)

    @books = []
    @books << @book
  end

  it 'should extend Array to add a #to_comma method which will return CSV content for objects within the array' do
    expected = "Title,Description,Issuer,ISBN-10,ISBN-13\nSmalltalk-80,Language and Implementation,ISBN,123123123,321321321\n" # rubocop:disable Metrics/LineLength
    expect(@books.to_comma).to eq(expected)
  end

  it 'should return an empty string when generating CSV from an empty array' do
    expect([].to_comma).to eq('')
  end

  it 'should change the style when specified' do
    expect(@books.to_comma(:brief)).to eq("Name,Description\nSmalltalk-80,Language and Implementation\n")
  end

  describe 'with :filename specified' do
    after { File.delete('comma.csv') }

    it 'should write to the file' do
      @books.to_comma(filename: 'comma.csv')
      expected = "Title,Description,Issuer,ISBN-10,ISBN-13\nSmalltalk-80,Language and Implementation,ISBN,123123123,321321321\n" # rubocop:disable Metrics/LineLength
      expect(File.read('comma.csv')).to eq(expected)
    end

    it 'should accept FasterCSV options' do
      @books.to_comma(filename: 'comma.csv', col_sep: ';', force_quotes: true)
      expected = "\"Title\";\"Description\";\"Issuer\";\"ISBN-10\";\"ISBN-13\"\n\"Smalltalk-80\";\"Language and Implementation\";\"ISBN\";\"123123123\";\"321321321\"\n" # rubocop:disable Metrics/LineLength
      expect(File.read('comma.csv')).to eq(expected)
    end
  end

  describe 'with FasterCSV options' do
    it 'should not change when options are empty' do
      expected = "Title,Description,Issuer,ISBN-10,ISBN-13\nSmalltalk-80,Language and Implementation,ISBN,123123123,321321321\n" # rubocop:disable Metrics/LineLength
      expect(@books.to_comma({})).to eq(expected)
    end

    it 'should accept the options in #to_comma and generate the appropriate CSV' do
      expected = "\"Title\";\"Description\";\"Issuer\";\"ISBN-10\";\"ISBN-13\"\n\"Smalltalk-80\";\"Language and Implementation\";\"ISBN\";\"123123123\";\"321321321\"\n" # rubocop:disable Metrics/LineLength
      expect(@books.to_comma(col_sep: ';', force_quotes: true)).to eq(expected)
    end

    it 'should change the style when specified' do
      expect(@books.to_comma(style: :brief, col_sep: ';', force_quotes: true))
        .to eq("\"Name\";\"Description\"\n\"Smalltalk-80\";\"Language and Implementation\"\n")
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
      expect(Foo.comma_formats).not_to be_empty
      expect(Foo.comma_formats[:default]).not_to be_nil
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
      expect(Bar.comma_formats).not_to be_empty
      expect(Bar.comma_formats[:default]).not_to be_nil
      expect(Bar.comma_formats[:detailed]).not_to be_nil
    end
  end
end

describe Comma, 'to_comma data/headers object extensions' do # rubocop:disable Metrics/BlockLength
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
      expect(@foo.to_comma).to eq(%w[content])
    end

    it 'should return and array of header content, using the :default CSV description if none requested' do
      expect(@foo.to_comma_headers).to eq(%w[Content])
    end

    it 'should return the CSV representation including header and content when called on an array' do
      expect(Array(@foo).to_comma).to eq("Content\ncontent\n")
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
      expect(@foo.to_comma(:detailed)).to eq(%w[content])
    end

    it 'should return and array of header content, using the :default CSV description if none requested' do
      expect(@foo.to_comma_headers(:detailed)).to eq(%w[Content])
    end

    it 'should return the CSV representation including header and content when called on an array' do
      expect(Array(@foo).to_comma(:detailed)).to eq("Content\ncontent\n")
    end

    it 'should raise an error if the requested description is not avaliable' do
      expect { @foo.to_comma(:bad) }.to raise_error
      expect { @foo.to_comma_headers(:bad) }.to raise_error
      expect { Array(@foo).to_comma(:bad) }.to raise_error
    end
  end

  describe 'with block' do # rubocop:disable BlockLength
    before do
      class Foo
        attr_accessor :content, :created_at, :updated_at
        comma do
          content
          content('Truncated Content') { |i| i && i.length > 10 ? i[0..10] : '---' }
          created_at { |i| i&.to_s(:db) }
          updated_at { |i| i&.to_s(:db) }
          created_at 'Created Custom Label' do |i| i&.to_s(:short) end
          updated_at 'Updated at Custom Label' do |i| i&.to_s(:short) end
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
      _header, foo = Array(@foo).to_comma.split("\n")
      expected = [
        @content,
        @content[0..10],
        @time.to_s(:db),
        @time.to_s(:db),
        @time.to_s(:short),
        @time.to_s(:short)
      ].join(',')
      expect(foo).to eq(expected)
    end

    it 'should return headers with custom labels from block' do
      header, _foo = Array(@foo).to_comma.split("\n")
      expected = [
        'Content',
        'Truncated Content',
        'Created at',
        'Updated at',
        'Created Custom Label',
        'Updated at Custom Label'
      ].join(',')
      expect(header).to eq(expected)
    end

    it 'should put headers in place when forced' do
      header, _foo = Array(@foo).to_comma(write_headers: true).split("\n")
      expected = [
        'Content',
        'Truncated Content',
        'Created at',
        'Updated at',
        'Created Custom Label',
        'Updated at Custom Label'
      ].join(',')
      expect(header).to eq(expected)
    end

    it 'should not write headers if specified' do
      header, _foo = Array(@foo).to_comma(write_headers: false).split("\n")
      expected = [
        @content,
        @content[0..10],
        @time.to_s(:db),
        @time.to_s(:db),
        @time.to_s(:short),
        @time.to_s(:short)
      ].join(',')
      expect(header).to eq(expected)
    end
  end

  describe 'on an object with no comma declaration' do
    it 'should raise an error mentioning there is no comma description defined for that class' do
      expect { 'a string'.to_comma }.to raise_error('No comma format for class String defined for style default')
      expect { 'a string'.to_comma_headers }
        .to raise_error('No comma format for class String defined for style default')
    end
  end

  describe 'on objects using Single Table Inheritance' do
    before do
      class MySuperClass
        attr_accessor :content
        comma do; content end

        def initialize(content)
          @content = 'super-' + content
        end
      end

      class ChildClassComma < MySuperClass
        comma do; content end

        def initialize(content)
          @content = 'sub-' + content
        end
      end

      class ChildClassNoComma < MySuperClass
      end

      @childComma = ChildClassComma.new('content')
      @childNoComma = ChildClassNoComma.new('content')
    end

    it 'should return and array of data content, as defined in comma block in child class' do
      expect(@childComma.to_comma).to eq(%w[sub-content])
    end

    it 'should return and array of data content, as defined in comma block in super class, if not present in child' do
      expect(@childNoComma.to_comma).to eq(%w[super-content])
    end
  end
end

describe Comma, '__use__ keyword' do
  before(:all) do
    @obj = Class.new(Struct.new(:id, :title, :description)) do
      comma do
        title
        __use__ :description
      end

      comma :description do
        __use__ :static
        description
      end

      comma :static do
        __static_column__ do 'Foo, Inc.' end
      end
    end.new(1, 'Programming Ruby', 'The Pickaxe book')
  end

  subject { @obj.to_comma }
  its(:size) { should eq(3) }
  it { should eq(['Programming Ruby', 'Foo, Inc.', 'The Pickaxe book']) }
end
