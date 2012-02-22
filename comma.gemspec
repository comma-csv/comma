# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "comma/version"

Gem::Specification.new do |s|
  s.name        = "comma"
  s.version     = Comma::VERSION
  s.authors     = ["Marcus Crafter", "Tom Meier"]
  s.email       = ["crafterm@redartisan.com", "tom@venombytes.com"]
  s.homepage    = "http://github.com/crafterm/comma"
  s.summary     = %q{Ruby Comma Seperated Values generation library}
  s.description = %q{Ruby Comma Seperated Values generation library}

  s.rubyforge_project = "comma"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency(%q<rake>, ["~> 0.9.2"])
  s.add_development_dependency('sqlite3', '~> 1.3.4')
  s.add_development_dependency(%q<appraisal>, ["~> 0.4.1"])

  s.add_development_dependency('rspec', '~> 2.8.0')
  s.add_development_dependency 'simplecov'

end
