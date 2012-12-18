require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'appraisal'

$LOAD_PATH.unshift("lib")
load 'tasks/shoulda.rake'

Rake::TestTask.new do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

desc 'Test the plugin under all supported Rails versions.'
task :all => ['appraisal:cleanup', 'appraisal:install'] do
  exec('rake appraisal test')
end

desc 'Default: run tests'
task :default => [:all]
