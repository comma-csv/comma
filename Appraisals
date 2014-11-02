['3.0.20', '3.1.12', '3.2.20', '4.0.11', '4.1.7'].each do |version_number|
  clean_number = version_number.gsub(/[<>~=]*/, '')
  next if RUBY_VERSION < '1.9.3' && version_number >= '4.0.0'

  appraise "rails#{ clean_number }" do
    gem "rails", version_number
    gem "rspec-rails"
  end

  appraise "active#{ clean_number }" do
    gem "activesupport", version_number
    gem "activerecord", version_number
  end
end

if RUBY_VERSION >= '1.9.3'
  appraise 'mongoid3.1.6' do
    gem 'mongoid', '3.1.6'
  end
end

appraise 'data_mapper1.2.0' do
  gem 'data_mapper', '1.2.0'
  gem 'dm-sqlite-adapter', '1.2.0'
end
