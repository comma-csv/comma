class Book
  attr_accessor :name, :description, :isbn

  def initialize(name, description, isbn)
    @name, @description, @isbn = name, description, isbn
  end

  comma do
    name 'Title'
    description

    isbn :authority => :issuer
    isbn :number_10 => 'ISBN-10'
    isbn :number_13 => 'ISBN-13'
  end

  comma :brief do
    name
    description
  end
end

class Isbn
  attr_accessor :number_10, :number_13

  def initialize(isbn_10, isbn_13)
    @number_10, @number_13 = isbn_10, isbn_13
  end

  def authority; 'ISBN'; end
end

class MultiAttributeField
  attr_accessor :name, :address, :number, :children

  def initialize(name, address, number, children = [])
    @name, @address, @number, @children =  name, address, number, children
  end

  comma do
    name
    multicolumn :children do |result, field, child|
      result << {'name' => 'OBJ ~ ID',    'value' => child.id}
      result << {'name' => 'OBJ ~ Name',  'value' => child.name}
      result << {'name' => 'OBJ ~ Value', 'value' => child.value}
    end
  end
end

class Field
  attr_accessor :name, :value

  def initialize(name, value)
    @name, @value = name, value
  end

  def id
    123
  end
end
