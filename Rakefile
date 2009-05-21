require 'rubygems'
require 'rubygems/gem_runner'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   "dm-yaml-adapter"
    s.version   =   "0.5"
    s.author    =   "Joshua Harding"
    s.email     =   "josh@statewidesoftware.com"
    s.summary   =   "a YAML adapter for DataMapper. this (slow) adapter allows you to use DataMapper with YAML files as a backing store."
    s.files     =   FileList['lib/*.rb', 'spec/*'].to_a
    s.require_path  =   "lib"
    s.autorequire   =   "dm-yaml-adapter"
    s.test_files = Dir.glob('spec/*.rb')
    s.has_rdoc  =   false
    s.extra_rdoc_files  =   ["README"]
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated latest version"
end

