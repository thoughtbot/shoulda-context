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
  s.executables      = `git ls-files -- exe/*`.split("\n").map{ |f| File.basename(f) }
  s.bindir           = 'exe'
  s.require_paths    = ["lib"]

  s.add_development_dependency "appraisal"
  s.add_development_dependency "bundler", "~> 1.0"
end
