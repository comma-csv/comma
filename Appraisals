['3.0.9', '3.1.1', '~>3.2.8' ].each do |version_number|
  clean_number = version_number.gsub(/[<>~=]*/, '')

  appraise "rails#{ clean_number }" do
    gem "rails", version_number
    gem "rspec-rails"
  end

  appraise "active#{ clean_number }" do
    gem "activesupport", version_number
    gem "activerecord", version_number
  end
end
