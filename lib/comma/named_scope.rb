#TODO : Rails 2.3.x Deprecations
class ActiveRecord::NamedScope::Scope
  def to_comma(style = :default)
    Comma::Generator.new(self, style).run(:find_each)
  end
end
