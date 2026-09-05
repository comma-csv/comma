# frozen_string_literal: true

module Comma
  module Options
    module_function

    def parse(input)
      return { style: input, filename: nil, csv: {} } unless input.is_a?(Hash)

      csv = input.dup
      style = csv.delete(:style) || Comma::DEFAULT_OPTIONS[:style]
      filename = csv.delete(:filename)
      csv[:write_headers] = csv[:write_headers] != 'false' if csv[:write_headers].is_a?(String)

      { style: style, filename: filename, csv: csv }
    end
  end
end
