['2.3.2', '2.3.5', '2.3.7', '2.3.14', '2.3.15' ].each do |version_number|
  clean_number = version_number.gsub(/[<>~=]*/, '')

  appraise "rails#{ clean_number }" do
    gem "rails", version_number
  end

  appraise "active#{ clean_number }" do
    gem "activesupport", version_number
    gem "activerecord", version_number
  end
end
