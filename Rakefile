require 'rubygems'
require 'rake/rdoctask'
require './lib/basset.rb'
require "spec/rake/spectask"
require "rake/clean"
require "rake/rdoctask"

desc "Run all of the specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "\"spec/spec.opts\""]
  t.fail_on_error = false
end

namespace :spec do

  desc "Run all spec with RCov" 
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.rcov = true
    t.rcov_dir = 'doc/tools/coverage/'
    t.rcov_opts = ['--exclude', 'spec']
  end

  desc "Generate HTML report for failing examples"
  Spec::Rake::SpecTask.new('report') do |t|
    t.spec_files = FileList['failing_examples/**/*.rb']
    t.spec_opts = ["--format", "html:doc/tools/reports/failing_examples.html", "--diff", '--options', '"spec/spec.opts"']
    t.fail_on_error = false
  end
  
end


Rake::RDocTask.new do |rdt|
  rdt.rdoc_dir = "doc"
  rdt.main = "README.rdoc"
  rdt.rdoc_files.include("README.rdoc", "lib/*", "ext/*/*.yy.c")
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = 'basset'
    s.summary = 'A library for machine learning and classification'
    s.description = s.summary
    s.email = 'ddeleo@basecommander.net'
    s.homepage = "http://github.com/danielsdeleo/basset"
    s.platform = Gem::Platform::RUBY 
    s.has_rdoc = true
    s.extra_rdoc_files = ["README.rdoc"]
    s.require_path = ["lib"]
    s.authors = ['Paul Dix', 'Bryan Helmkamp', 'Daniel DeLeo']
    s.add_dependency('stemmer', '>= 1.0.1') 
    # ruby -rpp -e' pp `git ls-files`.split("\n") '
    s.files = `git ls-files`.split("\n").reject {|f| f =~ /git/}
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc "outputs a list of files suitable for use with the gemspec"
task :list_files do
  sh %q{ruby -rpp -e' pp `git ls-files`.split("\n").reject {|f| f =~ /git/} '}
end
