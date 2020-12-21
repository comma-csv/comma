# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'comma/version'

Gem::Specification.new do |s|
  s.name        = 'comma'
  s.version     = Comma::VERSION
  s.authors     = ['Marcus Crafter', 'Tom Meier']
  s.email       = ['crafterm@redartisan.com', 'tom@venombytes.com']
  s.homepage    = 'http://github.com/comma-csv/comma'
  s.summary     = %(Ruby Comma Seperated Values generation library)
  s.description = %(Ruby Comma Seperated Values generation library)

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  s.licenses = ['MIT']

  s.add_dependency 'activesupport', ['>= 4.2.0', '< 6.2']

  s.add_development_dependency 'appraisal', ['~> 1.0.0']
  s.add_development_dependency 'rake', '~> 13.0.1'
  s.add_development_dependency 'rspec', ['~> 3.5.0']
  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'rspec-its'
end
