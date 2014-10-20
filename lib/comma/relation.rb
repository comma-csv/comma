class ActiveRecord::Relation
  def to_comma(style = :default)
    iterator_method =
      if arel.ast.limit || !arel.ast.orders.empty?
        Rails.logger.warn "#to_comma is being used on a relation with limit or order clauses. Falling back to iterating with :each. This can cause performance issues." if defined?(Rails)
        :each
      else
        :find_each
      end
    Comma::Generator.new(self, style).run(iterator_method)
  end
end
