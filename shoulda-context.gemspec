# -*- encoding: utf-8 -*-

$LOAD_PATH << File.join(File.dirname(__FILE__), "lib")
require "shoulda/context/version"

Gem::Specification.new do |s|
  s.name        = "shoulda-context"
  s.version     = Shoulda::Context::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["thoughtbot, inc.", "Tammer Saleh", "Joe Ferris",
                   "Ryan McGeary", "Dan Croak", "Matt Jankowski"]
  s.email       = "support@thoughtbot.com"
  s.homepage    = "http://thoughtbot.com/community/"
  s.summary     = "Context framework extracted from Shoulda"
  s.description = "Context framework extracted from Shoulda"
  s.license     = "MIT"

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- exe/*`.split("\n").map { |f| File.basename(f) }
  s.bindir           = "exe"
  s.require_paths    = ["lib"]

  s.add_development_dependency "appraisal"
  s.add_development_dependency "bundler", "~> 1.0"
  s.add_development_dependency "byebug"
  s.add_development_dependency "m"
  s.add_development_dependency "mocha"
  s.add_development_dependency "pry", "~> 0.12.0"
  s.add_development_dependency "pry-byebug", "~> 3.6.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "rubocop", "0.64.0"
  s.add_development_dependency "snowglobe", ">= 0.3.0"
end
