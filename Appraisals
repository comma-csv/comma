['4.0.13', '4.1.16', '4.2.7.1', '5.0.0.1'].each do |version_number|
  clean_number = version_number.gsub(/[<>~=]*/, '')

  appraise "rails#{ clean_number }" do
    gem "rails", version_number
    gem "rspec-rails"
    gem 'test-unit'
  end

  appraise "active#{ clean_number }" do
    gem "activesupport", version_number
    gem "activerecord", version_number
  end
end
