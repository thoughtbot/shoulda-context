require 'fileutils'
require 'test/unit'
require 'mocha'

if ENV['BUNDLE_GEMFILE'].to_s.empty?
  raise "No Appraisal is specified. Please re-run your tests with BUNDLE_GEMFILE set."
end

PROJECT_DIR = File.expand_path('../..', __FILE__)
CURRENT_APPRAISAL_NAME = File.basename(ENV['BUNDLE_GEMFILE'], '.gemfile')

$LOAD_PATH << File.join(PROJECT_DIR, 'lib')
require 'shoulda/context'

Shoulda.autoload_macros File.join(File.dirname(__FILE__), 'fake_rails_root'),
                        File.join("vendor", "{plugins,gems}", "*")
