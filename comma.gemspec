Gem::Specification.new do |s| 
  s.name = "comma"
  s.version = "0.2.2"
  s.author = "Marcus Crafter"
  s.email = "crafterm@redartisan.com"
  s.homepage = "http://github.com/crafterm/comma"
  s.platform = Gem::Platform::RUBY
  s.summary = "Ruby Comma Seperated Values generation library"
  s.files = %w( README.markdown MIT-LICENSE lib/comma.rb lib/comma/extractors.rb )
  s.require_path = "lib"
  s.add_dependency("activesupport", ">= 2.2.2")
end
