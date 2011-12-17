class ActiveRecord::Relation
  def to_comma(style = :default)
    Comma::Generator.new(self, style).run(:find_each)
  end
end