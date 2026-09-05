# frozen_string_literal: true

# Builds the expected CSV string from headers/rows so specs don't hand-roll
# comma-joined strings, then asserts it against the actual output.
# `csv_options` are forwarded to CSV.generate (e.g. col_sep:, force_quotes:).
#
#   expect_csv(books.to_comma, headers: %w[Title Author], rows: [['Smalltalk-80', 'Kay']])
def expect_csv(output, headers:, rows:, **csv_options)
  expected = CSV.generate(**csv_options) do |csv|
    csv << headers
    rows.each { |row| csv << row }
  end
  expect(output).to eq(expected)
end
