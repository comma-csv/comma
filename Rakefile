require 'rake/gempackagetask'

spec = Gem::Specification.new do |s| 
  s.name = "comma"
  s.version = "0.2.2"
  s.author = "Marcus Crafter"
  s.email = "crafterm@redartisan.com"
  s.homepage = "http://github.com/crafterm/comma"
  s.platform = Gem::Platform::RUBY
  s.summary = "Ruby Comma Seperated Values generation library"
  s.files = %w( README.markdown MIT-LICENSE lib/comma.rb lib/comma/extractors.rb )
  s.require_path = "lib"
  s.add_dependency("fastercsv", ">= 1.4.0")
  s.add_dependency("activesupport", ">= 2.2.2")
end

Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = false
end

begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  require 'spec'
end
begin
  require 'spec/rake/spectask'
rescue LoadError
  puts <<-EOS
To use rspec for testing you must install rspec gem:
    gem install rspec
EOS
  exit(0)
end

desc "Run the specs under spec"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end
