# -*- coding: utf-8 -*-

class DataMapper::Collection
  def to_comma(style = :default)
    Comma::Generator.new(self, style).run(:each)
  end
end
