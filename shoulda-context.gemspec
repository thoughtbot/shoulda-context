# -*- encoding: utf-8 -*-
$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'shoulda/context/version'

Gem::Specification.new do |s|
  s.name        = %q{shoulda-context}
  s.version     = Shoulda::Context::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["thoughtbot, inc.", "Tammer Saleh", "Joe Ferris",
                   "Ryan McGeary", "Dan Croak", "Matt Jankowski"]
  s.email       = %q{support@thoughtbot.com}
  s.homepage    = %q{http://thoughtbot.com/community/}
  s.summary     = %q{Context framework extracted from Shoulda}
  s.description = %q{Context framework extracted from Shoulda}
  s.license     = %q{MIT}

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths    = ["lib"]

  s.add_development_dependency("appraisal", "~> 0.5")
  s.add_development_dependency("rails", ">= 3.0")
  s.add_development_dependency("mocha", "~> 0.9.10")
  s.add_development_dependency("rake")
  s.add_development_dependency("test-unit", "~> 2.1.0")
end
