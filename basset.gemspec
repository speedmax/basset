# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{basset}
  s.version = "1.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Dix", "Bryan Helmkamp", "Daniel DeLeo", "R. Potter"]
  s.date = %q{2009-05-09}
  s.description = %q{A library for machine learning and classification}
  s.email = %q{rjspotter@gmail.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["History.txt", "License.txt", "Manifest.txt", "README.rdoc", "Rakefile", "VERSION.yml", "basset.gemspec", "examples/example.rb", "lib/basset.rb", "lib/basset/classification_evaluator.rb", "lib/basset/classifier.rb", "lib/basset/core_extensions.rb", "lib/basset/document.rb", "lib/basset/document_override_example.rb", "lib/basset/feature.rb", "lib/basset/feature_extractor.rb", "lib/basset/feature_selector.rb", "lib/basset/naive_bayes.rb", "lib/basset/svm.rb", "lib/basset/yaml_serialization.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/unit/classifier_spec.rb", "spec/unit/core_extension_spec.rb", "spec/unit/document_spec.rb", "spec/unit/feature_extractor_spec.rb", "spec/unit/feature_selector_spec.rb", "spec/unit/feature_spec.rb", "spec/unit/naive_bayes_spec.rb", "spec/unit/svm_spec.rb"]
  s.homepage = %q{http://github.com/danielsdeleo/basset}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = [["lib"]]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{A library for machine learning and classification}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<stemmer>, [">= 1.0.1"])
      s.add_runtime_dependency(%q<tomz-libsvm-ruby-swig>, [">= 0.3.3"])
      s.add_runtime_dependency(%q<igrigorik-bloomfilter>, [">= 0.1.2"])
    else
      s.add_dependency(%q<stemmer>, [">= 1.0.1"])
      s.add_dependency(%q<tomz-libsvm-ruby-swig>, [">= 0.3.3"])
      s.add_dependency(%q<igrigorik-bloomfilter>, [">= 0.1.2"])
    end
  else
    s.add_dependency(%q<stemmer>, [">= 1.0.1"])
    s.add_dependency(%q<tomz-libsvm-ruby-swig>, [">= 0.3.3"])
    s.add_dependency(%q<igrigorik-bloomfilter>, [">= 0.1.2"])
  end
end
