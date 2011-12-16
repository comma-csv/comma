class ActiveRecord::Relation
  def to_comma(style = :default)
    Comma::Generator.new(self.all, style).run(:find_each)
  end
end