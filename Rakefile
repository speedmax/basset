PKG_VERSION = "1.0.2"

require 'rubygems'
require "rake"
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'spec/rake/spectask'
require './lib/basset.rb'

desc "Run all of the specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "\"spec/spec.opts\""]
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

gemspec = Gem::Specification.new do |p|
  p.platform = Gem::Platform::RUBY
  p.summary = 'A library for machine learning and classification'
  p.name = "basset"
  p.version = PKG_VERSION
  p.require_path = 'lib'
  p.authors = ['Paul Dix', 'Bryan Helmkamp', 'Daniel DeLeo']
  p.email = 'paul@pauldix.net'
 
  p.description = 
%q{
This is Daniel DeLeo's fork of Paul Dix's basset[http://github.com/pauldix/basset/], a library for machine learning.

Basset includes a generic document representation class, a feature selector, a feature extractor, naive bayes  and SVM classifiers, and a classification evaluator for running tests. The goal is to create a general framework that is easy to modify for specific problems. It is designed to be extensible so it should be easy to add more classification and clustering algorithms.
}
  p.dependencies << ['stemmer', '>= 1.0.1'] 
end

Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end