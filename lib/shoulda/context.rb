if !defined?(Test::Unit::TestCase)
  require 'test/unit/testcase'
end

require 'shoulda/context/version'
require 'shoulda/context/proc_extensions'
require 'shoulda/context/assertions'
require 'shoulda/context/context'
require 'shoulda/context/autoload_macros'

class Test::Unit::TestCase
  include Shoulda::Context::Assertions
  include Shoulda::Context::InstanceMethods
  extend Shoulda::Context::ClassMethods
end
