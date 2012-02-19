class ActiveRecord::Associations::AssociationProxy
  def to_comma(style = :default)
    #Bug in Rails 2.3.5, this is a workaround as association_proxy.rb doesn't pass the &block in the send method so it silently fails
    Comma::Generator.new(Array(self), style).run(:each)
  end
end
