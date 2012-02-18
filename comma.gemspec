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

  s.add_runtime_dependency(%q<fastercsv>, ["1.5.4"])

  s.add_development_dependency(%q<rake>, ["0.8.7"])
  s.add_development_dependency('sqlite3', '~> 1.3.4')
  s.add_development_dependency(%q<rspec>, ["~> 2.7.0"])
  s.add_development_dependency(%q<appraisal>, [">= 0.4.0"])

end
