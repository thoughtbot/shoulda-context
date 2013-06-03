begin
  # if present, load and set base_test_case
  ActiveSupport::TestCase
  if defined?([ActiveSupport::TestCase, MiniTest::Unit::TestCase]) &&
     (ActiveSupport::TestCase.ancestors.include?(MiniTest::Unit::TestCase))
    base_test_case = MiniTest::Unit::TestCase
  end
rescue
end

# no base_test_case set, using Test:Unit:TestCase
unless base_test_case
  require 'test/unit/testcase' unless defined?(Test::Unit::TestCase)
  base_test_case = Test::Unit::TestCase
end

require 'shoulda/context/version'
require 'shoulda/context/proc_extensions'
require 'shoulda/context/assertions'
require 'shoulda/context/context'
require 'shoulda/context/autoload_macros'

module ShouldaContextLoadable
  def self.included(base)
    base.class_eval do
      include Shoulda::Context::Assertions
      include Shoulda::Context::InstanceMethods
    end
    base.extend(Shoulda::Context::ClassMethods)
  end
end

base_test_case.class_eval { include ShouldaContextLoadable }
