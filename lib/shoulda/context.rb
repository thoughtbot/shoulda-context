require 'shoulda/context/test_framework_detection'
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

Shoulda::Context.test_framework_test_cases.each do |test_case|
  test_case.class_eval { include ShouldaContextLoadable }
end
