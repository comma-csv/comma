class Array
  def to_comma(style = :default)
    options = {}

    if style.is_a? Hash
      options = style
      style = options.delete(:style)||:default
    end

    FasterCSV.generate(options) do |csv|
      return "" if empty?
      csv << first.to_comma_headers(style) # REVISIT: request to optionally include headers
      each do |object| 
        csv << object.to_comma(style)
      end
    end
  end
end
