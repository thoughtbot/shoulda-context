$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'shoulda/context/version'

Gem::Specification.new do |s|
  s.name = %q{shoulda-context}
  s.version = Shoulda::Context::VERSION.dup

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["thoughtbot, inc.", "Tammer Saleh", "Joe Ferris",
               "Ryan McGeary", "Dan Croak", "Matt Jankowski"]
  s.date = Time.now.strftime("%Y-%m-%d")
  s.email = %q{support@thoughtbot.com}
  s.executables = ["convert_to_should_syntax"]
  s.extra_rdoc_files = ["README.rdoc", "CONTRIBUTION_GUIDELINES.rdoc"]
  s.files = Dir["[A-Z]*", "{bin,lib,rails,test}/**/*", "init.rb"]
  s.homepage = %q{http://thoughtbot.com/community/}
  s.rdoc_options = ["--line-numbers", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Context framework extracted from Shoulda}
  s.description = %q{Context framework extracted from Shoulda}

  s.add_development_dependency "mocha", "~> 0.9.10"
  s.add_development_dependency "rake"

  if s.respond_to? :specification_version then
    s.specification_version = 3
  else
  end
end
