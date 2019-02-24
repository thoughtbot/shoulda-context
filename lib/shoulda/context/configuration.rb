module Shoulda
  module Context
    # Configures the gem's behavior. Place a configuration block in your test
    # helper to set up Shoulda::Context for your project.
    #
    # @example
    #   Shoulda::Context.configure do |config|
    #     config.include(MyHelpers)
    #   end
    #
    # @see Shoulda::Context.include
    # @see Shoulda::Context.extend
    def self.configure
      yield self
    end

    # Mixes a module into all top-level test case classes that Shoulda::Context
    # thinks are present, as instance methods. Useful for assertions or other
    # methods that you want to use within the context of a test.
    #
    # @param mod [Module]
    # @return [void]
    def self.include(mod)
      test_framework_test_cases.each do |test_case|
        test_case.class_eval { include mod }
      end
    end

    # Mixes a module into all top-level test case classes that Shoulda::Context
    # thinks are present, as class methods. Useful for macros (methods that
    # generate test methods).
    #
    # @param mod [Module]
    # @return [void]
    def self.extend(mod)
      test_framework_test_cases.each do |test_case|
        test_case.extend(mod)
      end
    end
  end
end
