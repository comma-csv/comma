# frozen_string_literal: true

[
  '5.0.7.2',
  '5.1.7',
  '5.2.4.3'
].each do |version_number|
  clean_number = version_number.gsub(/[<>~=]*/, '')

  appraise "rails#{clean_number}" do
    gem 'rails', version_number
    gem 'rspec-rails'
    gem 'sprockets', '< 4'
    gem 'sqlite3', '~> 1.3.11'
    gem 'test-unit'
  end

  appraise "active#{clean_number}" do
    gem 'activesupport', version_number
    gem 'activerecord', version_number
  end
end

appraise 'rails6.0.3.1' do
  gem 'rails', '6.0.3.1'
  gem 'rspec-rails'
  gem 'test-unit'
end

appraise 'active6.0.3.1' do
  gem 'activesupport', '6.0.3.1'
  gem 'activerecord', '6.0.3.1'
end

appraise 'rails6.1.0' do
  gem 'rails', '6.1.0'
  gem 'rspec-rails'
  gem 'test-unit'
end

appraise 'active6.1.0' do
  gem 'activesupport', '6.1.0'
  gem 'activerecord', '6.1.0'
end

appraise 'railsedge' do
  gem 'rails', git: 'git@github.com:rails/rails.git', branch: 'main'
  gem 'activesupport'
  gem 'activerecord'
end