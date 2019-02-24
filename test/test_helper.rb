TEST_FRAMEWORK = ENV.fetch("TEST_FRAMEWORK", "minitest")

if TEST_FRAMEWORK == "test_unit"
  require "test-unit"
  require "mocha/test_unit"
else
  require "minitest/autorun"
  require "mocha/minitest"
end

require "pry-byebug"
require "appraisal"
require "fileutils"

appraisal_in_use =
  Pathname.new(ENV["BUNDLE_GEMFILE"]).expand_path.dirname ==
  Pathname.new("../../gemfiles").expand_path(__FILE__)

unless appraisal_in_use
  raise <<-MSG
No Appraisal is specified.

Please run tests starting with `appraisal <appraisal_name>`.
Possible appraisals are: #{Appraisal::AppraisalFile.each.map(&:name)}
  MSG
end

PROJECT_DIR = File.expand_path("..", __dir__)
CURRENT_APPRAISAL_NAME = File.basename(ENV["BUNDLE_GEMFILE"], ".gemfile")
PARENT_TEST_CASE =
  if TEST_FRAMEWORK == "test_unit"
    Test::Unit::TestCase
  else
    Minitest::Test
  end
ASSERTION_CLASS =
  if TEST_FRAMEWORK == "test_unit"
    Test::Unit::AssertionFailedError
  else
    Minitest::Assertion
  end

$LOAD_PATH << File.join(PROJECT_DIR, "lib")
require "shoulda/context"

Shoulda.autoload_macros File.join(File.dirname(__FILE__), "fake_rails_root"),
  File.join("vendor", "{plugins,gems}", "*")

require_relative "./support/rails_application_with_shoulda_context"
