begin
  # if present, then also loads MiniTest::Spec
  ActiveSupport::TestCase
rescue
end

if defined?([ActiveSupport::TestCase, MiniTest::Spec]) && (ActiveSupport::TestCase.ancestors.include?(MiniTest::Spec))
  base_test_case = MiniTest::Spec
else
  if !defined?(Test::Unit::TestCase)
    require 'test/unit/testcase'
  end
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
