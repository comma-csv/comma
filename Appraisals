['3.0.9', '3.1.1', '3.1.12', '3.2.11', '4.0.0'].each do |version_number|
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
  appraise 'mongoid3.1.4' do
    gem 'mongoid', '3.1.4'
  end
end
