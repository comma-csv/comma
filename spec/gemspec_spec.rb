# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'comma.gemspec' do
  it 'requires Ruby 3.1 or later' do
    specification = Gem::Specification.load(File.expand_path('../comma.gemspec', __dir__))

    expect(specification.required_ruby_version.to_s).to eq('>= 3.1')
  end
end
