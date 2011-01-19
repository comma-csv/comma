class ActiveRecord::Relation
  def to_comma(style = :default)
    Comma::Generator.new(self.all, style).run(:each)
  end
end
