module Shoulda
  module Context
    class << self
      def contexts # :nodoc:
        @contexts ||= []
      end
      attr_writer :contexts

      def current_context # :nodoc:
        self.contexts.last
      end

      def add_context(context) # :nodoc:
        self.contexts.push(context)
      end

      def remove_context # :nodoc:
        self.contexts.pop
      end
    end

    module ClassMethods
      # == Should statements
      #
      # Should statements are just syntactic sugar over normal Test::Unit test
      # methods.  A should block contains all the normal code and assertions
      # you're used to seeing, with the added benefit that they can be wrapped
      # inside context blocks (see below).
      #
      # === Example:
      #
      #  class UserTest < Test::Unit::TestCase
      #
      #    def setup
      #      @user = User.new("John", "Doe")
      #    end
      #
      #    should "return its full name"
      #      assert_equal 'John Doe', @user.full_name
      #    end
      #
      #  end
      #
      # ...will produce the following test:
      # * <tt>"test: User should return its full name. "</tt>
      #
      # Note: The part before <tt>should</tt> in the test name is gleamed from the name of the Test::Unit class.
      #
      # Should statements can also take a Proc as a <tt>:before </tt>option.  This proc runs after any
      # parent context's setups but before the current context's setup.
      #
      # === Example:
      #
      #  context "Some context" do
      #    setup { puts("I run after the :before proc") }
      #
      #    should "run a :before proc", :before => lambda { puts("I run before the setup") }  do
      #      assert true
      #    end
      #  end
      #
      # Should statements can also wrap matchers, making virtually any matcher
      # usable in a macro style. The matcher's description is used to generate a
      # test name and failure message, and the test will pass if the matcher
      # matches the subject.
      #
      # === Example:
      #
      #   should validate_presence_of(:first_name).with_message(/gotta be there/)
      #

      def should(name_or_matcher, options = {}, &blk)
        if Shoulda::Context.current_context
          Shoulda::Context.current_context.should(name_or_matcher, options, &blk)
        else
          context_name = self.name.gsub(/Test/, "") if self.name
          context = Shoulda::Context::Context.new(context_name, self) do
            should(name_or_matcher, options, &blk)
          end
          context.build
        end
      end

      # Allows negative tests using matchers. The matcher's description is used
      # to generate a test name and negative failure message, and the test will
      # pass unless the matcher matches the subject.
      #
      # === Example:
      #
      #   should_not set_the_flash
      def should_not(matcher)
        if Shoulda::Context.current_context
          Shoulda::Context.current_context.should_not(matcher)
        else
          context_name = self.name.gsub(/Test/, "") if self.name
          context = Shoulda::Context::Context.new(context_name, self) do
            should_not(matcher)
          end
          context.build
        end
      end

      # == Before statements
      #
      # Before statements are should statements that run before the current
      # context's setup. These are especially useful when setting expectations.
      #
      # === Example:
      #
      #  class UserControllerTest < Test::Unit::TestCase
      #    context "the index action" do
      #      setup do
      #        @users = [Factory(:user)]
      #        User.stubs(:find).returns(@users)
      #      end
      #
      #      context "on GET" do
      #        setup { get :index }
      #
      #        should respond_with(:success)
      #
      #        # runs before "get :index"
      #        before_should "find all users" do
      #          User.expects(:find).with(:all).returns(@users)
      #        end
      #      end
      #    end
      #  end
      def before_should(name, &blk)
        should(name, :before => blk) { assert true }
      end

      # Just like should, but never runs, and instead prints an 'X' in the Test::Unit output.
      def should_eventually(name, options = {}, &blk)
        context_name = self.name.gsub(/Test/, "")
        context = Shoulda::Context::Context.new(context_name, self) do
          should_eventually(name, &blk)
        end
        context.build
      end

      # == Contexts
      #
      # A context block groups should statements under a common set of setup/teardown methods.
      # Context blocks can be arbitrarily nested, and can do wonders for improving the maintainability
      # and readability of your test code.
      #
      # A context block can contain setup, should, should_eventually, and teardown blocks.
      #
      #  class UserTest < Test::Unit::TestCase
      #    context "A User instance" do
      #      setup do
      #        @user = User.find(:first)
      #      end
      #
      #      should "return its full name"
      #        assert_equal 'John Doe', @user.full_name
      #      end
      #    end
      #  end
      #
      # This code will produce the method <tt>"test: A User instance should return its full name. "</tt>.
      #
      # Contexts may be nested.  Nested contexts run their setup blocks from out to in before each
      # should statement.  They then run their teardown blocks from in to out after each should statement.
      #
      #  class UserTest < Test::Unit::TestCase
      #    context "A User instance" do
      #      setup do
      #        @user = User.find(:first)
      #      end
      #
      #      should "return its full name"
      #        assert_equal 'John Doe', @user.full_name
      #      end
      #
      #      context "with a profile" do
      #        setup do
      #          @user.profile = Profile.find(:first)
      #        end
      #
      #        should "return true when sent :has_profile?"
      #          assert @user.has_profile?
      #        end
      #      end
      #    end
      #  end
      #
      # This code will produce the following methods
      # * <tt>"test: A User instance should return its full name. "</tt>
      # * <tt>"test: A User instance with a profile should return true when sent :has_profile?. "</tt>
      #
      # <b>Just like should statements, a context block can exist next to normal <tt>def test_the_old_way; end</tt>
      # tests</b>.  This means you do not have to fully commit to the context/should syntax in a test file.

      def context(name, &blk)
        if Shoulda::Context.current_context
          Shoulda::Context.current_context.context(name, &blk)
        else
          context = Shoulda::Context::Context.new(name, self, &blk)
          context.build
        end
      end

      # Returns the class being tested, as determined by the test class name.
      #
      #   class UserTest; described_type; end
      #   # => User
      def described_type
        @described_type ||= self.name.
          gsub(/Test$/, '').
          split('::').
          inject(Object) { |parent, local_name| parent.const_get(local_name) }
      end

      # Sets the return value of the subject instance method:
      #
      #   class UserTest < Test::Unit::TestCase
      #     subject { User.first }
      #
      #     # uses the existing user
      #     should validate_uniqueness_of(:email)
      #   end
      def subject(&block)
        @subject_block = block
      end

      def subject_block # :nodoc:
        @subject_block ||= nil
      end
    end

    module InstanceMethods
      # Returns an instance of the class under test.
      #
      #   class UserTest
      #     should "be a user" do
      #       assert_kind_of User, subject # passes
      #     end
      #   end
      #
      # The subject can be explicitly set using the subject class method:
      #
      #   class UserTest
      #     subject { User.first }
      #     should "be an existing user" do
      #       assert !subject.new_record? # uses the first user
      #     end
      #   end
      #
      # The subject is used by all macros that require an instance of the class
      # being tested.
      def subject
        @shoulda_subject ||= construct_subject
      end

      def subject_block # :nodoc:
        (@shoulda_context && @shoulda_context.subject_block) || self.class.subject_block
      end

      def get_instance_of(object_or_klass) # :nodoc:
        if object_or_klass.is_a?(Class)
          object_or_klass.new
        else
          object_or_klass
        end
      end

      def instance_variable_name_for(klass) # :nodoc:
        klass.to_s.split('::').last.underscore
      end

      private

      def construct_subject
        if subject_block
          instance_eval(&subject_block)
        else
          get_instance_of(self.class.described_type)
        end
      end
    end

    class Context # :nodoc:

      attr_accessor :name               # my name
      attr_accessor :parent             # may be another context, or the original test::unit class.
      attr_accessor :subcontexts        # array of contexts nested under myself
      attr_accessor :setup_blocks       # blocks given via setup methods
      attr_accessor :teardown_blocks    # blocks given via teardown methods
      attr_accessor :shoulds            # array of hashes representing the should statements
      attr_accessor :should_eventuallys # array of hashes representing the should eventually statements

      # accessor with cache
      def subject_block
        return @subject_block if @subject_block
        parent.subject_block
      end
      attr_writer :subject_block

      def initialize(name, parent, &blk)
        Shoulda::Context.add_context(self)
        self.name               = name
        self.parent             = parent
        self.setup_blocks       = []
        self.teardown_blocks    = []
        self.shoulds            = []
        self.should_eventuallys = []
        self.subcontexts        = []
        self.subject_block      = nil

        if block_given?
          merge_block(&blk)
        else
          merge_block { warn "  * WARNING: Block missing for context '#{full_name}'" }
        end
        Shoulda::Context.remove_context
      end

      def merge_block(&blk)
        if self.respond_to?(:instance_exec)
          self.instance_exec(&blk)
        else
          # deprecated in Rails 4.x
          blk.bind(self).call
        end
      end

      def context(name, &blk)
        self.subcontexts << Context.new(name, self, &blk)
      end

      def setup(&blk)
        self.setup_blocks << blk
      end

      def teardown(&blk)
        self.teardown_blocks << blk
      end

      def should(name_or_matcher, options = {}, &blk)
        if name_or_matcher.respond_to?(:description) && name_or_matcher.respond_to?(:matches?)
          name = name_or_matcher.description
          blk = lambda { assert_accepts name_or_matcher, subject }
        else
          name = name_or_matcher
        end

        if blk
          self.shoulds << { :name => name, :before => options[:before], :block => blk }
        else
          self.should_eventuallys << { :name => name }
        end
      end

      def should_not(matcher)
        name = matcher.description
        blk = lambda { assert_rejects matcher, subject }
        self.shoulds << { :name => "not #{name}", :block => blk }
      end

      def should_eventually(name, &blk)
        self.should_eventuallys << { :name => name, :block => blk }
      end

      def subject(&block)
        self.subject_block = block
      end

      def full_name
        parent_name = parent.full_name if am_subcontext?
        return [parent_name, name].join(" ").strip
      end

      def am_subcontext?
        parent.is_a?(self.class) # my parent is the same class as myself.
      end

      def test_unit_class
        am_subcontext? ? parent.test_unit_class : parent
      end

      def test_methods
        @test_methods ||= Hash.new { |h,k|
          h[k] = Hash[k.instance_methods.map { |n| [n, true] }]
        }
      end

      def create_test_from_should_hash(should)
        test_name = ["test:", full_name, "should", "#{should[:name]}. "].flatten.join(' ').to_sym

        if test_methods[test_unit_class][test_name.to_s] then
          raise DuplicateTestError, "'#{test_name}' is defined more than once."
        end

        test_methods[test_unit_class][test_name.to_s] = true

        context = self
        test_unit_class.send(:define_method, test_name) do
          @shoulda_context = context
          begin
            context.run_parent_setup_blocks(self)
            if should[:before]
              if self.respond_to?(:instance_exec)
                self.instance_exec(&should[:before])
              else
                # deprecated in Rails 4.x
                should[:before].bind(self).call
              end
            end
            context.run_current_setup_blocks(self)
            if self.respond_to?(:instance_exec)
              self.instance_exec(&should[:block])
            else
              # deprecated in Rails 4.x
              should[:block].bind(self).call
            end
          ensure
            context.run_all_teardown_blocks(self)
          end
        end
      end

      def run_all_setup_blocks(binding)
        run_parent_setup_blocks(binding)
        run_current_setup_blocks(binding)
      end

      def run_parent_setup_blocks(binding)
        self.parent.run_all_setup_blocks(binding) if am_subcontext?
      end

      def run_current_setup_blocks(binding)
        setup_blocks.each do |setup_block|
          if binding.respond_to?(:instance_exec)
            binding.instance_exec(&setup_block)
          else
            # deprecated in Rails 4.x
            setup_block.bind(binding).call
          end
        end
      end

      def run_all_teardown_blocks(binding)
        teardown_blocks.reverse.each do |teardown_block|
          if binding.respond_to?(:instance_exec)
            binding.instance_exec(&teardown_block)
          else
            # deprecated in Rails 4.x
            teardown_block.bind(binding).call
          end
        end
        self.parent.run_all_teardown_blocks(binding) if am_subcontext?
      end

      def print_should_eventuallys
        should_eventuallys.each do |should|
          test_name = [full_name, "should", "#{should[:name]}. "].flatten.join(' ')
          puts "  * DEFERRED: " + test_name
        end
      end

      def build
        shoulds.each do |should|
          create_test_from_should_hash(should)
        end

        subcontexts.each { |context| context.build }

        print_should_eventuallys
      end

      def method_missing(method, *args, &blk)
        test_unit_class.send(method, *args, &blk)
      end

    end
  end
end

class DuplicateTestError < RuntimeError; end
