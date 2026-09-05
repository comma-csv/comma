# frozen_string_literal: true

require 'spec_helper'

describe Comma::Options do # rubocop:disable Metrics/BlockLength
  describe '.parse' do # rubocop:disable Metrics/BlockLength
    it 'treats a bare symbol as the style, with no filename or csv options' do
      expect(described_class.parse(:brief)).to eq(style: :brief, filename: nil, csv: {})
    end

    it 'passes a bare nil through unchanged rather than defaulting it' do
      expect(described_class.parse(nil)).to eq(style: nil, filename: nil, csv: {})
    end

    it 'passes a bare false through unchanged rather than defaulting it' do
      expect(described_class.parse(false)).to eq(style: false, filename: nil, csv: {})
    end

    it 'extracts :style from a hash, defaulting to :default when absent' do
      result = described_class.parse(col_sep: ';')
      expect(result[:style]).to eq(:default)
      expect(result[:csv]).to eq(col_sep: ';')
    end

    it 'extracts an explicit :style from a hash' do
      result = described_class.parse(style: :brief, col_sep: ';')
      expect(result[:style]).to eq(:brief)
      expect(result[:csv]).to eq(col_sep: ';')
    end

    it 'extracts :filename from a hash and excludes it from :csv' do
      result = described_class.parse(filename: 'export.csv', col_sep: ';')
      expect(result[:filename]).to eq('export.csv')
      expect(result[:csv]).to eq(col_sep: ';')
    end

    it 'passes through a real boolean write_headers unchanged' do
      result = described_class.parse(write_headers: false)
      expect(result[:csv]).to eq(write_headers: false)
    end

    it 'coerces the string "false" for write_headers to boolean false' do
      result = described_class.parse(write_headers: 'false')
      expect(result[:csv]).to eq(write_headers: false)
    end

    it 'coerces any other string for write_headers to boolean true' do
      result = described_class.parse(write_headers: 'true')
      expect(result[:csv]).to eq(write_headers: true)
    end

    it 'does not mutate the input hash' do
      input = { style: :brief, filename: 'f.csv', col_sep: ';' }
      described_class.parse(input)
      expect(input).to eq(style: :brief, filename: 'f.csv', col_sep: ';')
    end

    it 'does not raise when given a frozen hash' do
      input = { style: :brief, col_sep: ';' }.freeze
      expect { described_class.parse(input) }.not_to raise_error
    end
  end
end
