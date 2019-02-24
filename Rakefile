require "bundler/setup"
require "bundler/gem_tasks"
require "rake/testtask"
require "appraisal"

require_relative "tasks/documentation"

Rake::TestTask.new do |t|
  t.libs << "lib" << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = false
end

task :default do
  if ENV["BUNDLE_GEMFILE"]
    exec "rake test --trace"
  else
    exec "appraisal install && appraisal rake test --trace"
  end
end

Shoulda::Context::DocumentationTasks.create

task release: "docs:publish_latest"
