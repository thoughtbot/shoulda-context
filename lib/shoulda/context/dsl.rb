require "shoulda/context/assertions"

module Shoulda
  module Context
    module DSL
      def self.included(base)
        base.class_eval do
          include Assertions
          include InstanceMethods
        end
        base.extend(ClassMethods)
      end

      module ClassMethods
        # `should` statements are just syntactic sugar over normal Test::Unit
        # test methods. A `should` block contains all the normal code and
        # assertions you're used to seeing, with the added benefit that they can
        # be wrapped inside `context` blocks (see below).
        #
        # For example, this test case:
        #
        #     class UserTest < Minitest::Test
        #       def setup
        #         @user = User.new("John", "Doe")
        #       end
        #
        #       should "return its full name"
        #         assert_equal 'John Doe', @user.full_name
        #       end
        #     end
        #
        # ...will produce the following test:
        #
        # * `"test: User should return its full name. "`
        #
        # The part before `should` in the test name is gleaned from the name of
        # the test case class.
        #
        # `should` statements can also take a proc as a `:before` option. This
        # proc runs after any parent context's `setup`s but before the current
        # context's `setup`.
        #
        # **Example:**
        #
        #     class SomeTest < Minitest::Test
        #       context "Some context" do
        #         setup { puts("I run after the :before proc") }
        #
        #         should "run a :before proc", before: -> { puts("I run before the setup") } do
        #           assert true
        #         end
        #       end
        #     end
        #
        # `should` statements can also wrap matchers, making virtually any
        # matcher usable in a macro style. The matcher's description is used to
        # generate a test name and failure message, and the test will pass if
        # the matcher matches the subject.
        #
        # **Example:**
        #
        #     should validate_presence_of(:first_name).with_message(/gotta be there/)
        #
        # @return [Shoulda::Context::Context]
        #
        def should(name_or_matcher, options = {}, &blk)
          if Shoulda::Context.current_context
            Shoulda::Context.current_context.should(name_or_matcher, options, &blk)
          else
            context_name = self.name.gsub(/Test$/, "") if name
            context = Shoulda::Context::Context.new(context_name, self) do
              should(name_or_matcher, options, &blk)
            end
            context.build
          end
        end

        # Allows negative tests using matchers. The matcher's description is
        # used to generate a test name and negative failure message, and the
        # test will pass unless the matcher matches the subject.
        #
        # **Example:**
        #
        #   should_not set_the_flash
        #
        # @return [Shoulda::Context::Context]
        #
        def should_not(matcher)
          if Shoulda::Context.current_context
            Shoulda::Context.current_context.should_not(matcher)
          else
            context_name = self.name.gsub(/Test$/, "") if name
            context = Shoulda::Context::Context.new(context_name, self) do
              should_not(matcher)
            end
            context.build
          end
        end

        # `before_should` statements are `should` statements that run before the
        # current context's `setup`. These are especially useful when setting
        # expectations.
        #
        # **Example:**
        #
        #     # This would actually be a different parent class, but you get the idea
        #     class UsersControllerTest < Minitest::Test
        #       context "the index action" do
        #         setup do
        #           @users = [FactoryBot.create(:user)]
        #           User.stubs(:find).returns(@users)
        #         end
        #
        #         context "on GET" do
        #           setup { get :index }
        #
        #           should respond_with(:success)
        #
        #           # this actually runs before "get :index"
        #           before_should "find all users" do
        #             User.expects(:find).with(:all).returns(@users)
        #           end
        #         end
        #       end
        #     end
        #
        # @return [Shoulda::Context::Context]
        #
        def before_should(name, &blk)
          should(name, :before => blk) { assert true }
        end

        # Just like `should`, but never runs, instead printing an 'X' when the
        # test is run.
        #
        # @return [Shoulda::Context::Context]
        #
        def should_eventually(name, options = {}, &blk)
          context_name = self.name.gsub(/Test$/, "")
          context = Shoulda::Context::Context.new(context_name, self) do
            should_eventually(name, &blk)
          end
          context.build
        end

        # A `context` block groups `should` statements under a common set of
        # setup/teardown methods. Context blocks can be arbitrarily nested, and
        # can do wonders for improving the maintainability and readability of
        # your test code.
        #
        # A `context` block can contain `setup`, `should`, `should_eventually`,
        # and `teardown` blocks.
        #
        #     class UserTest < Minitest::Test
        #       context "A User instance" do
        #         setup do
        #           @user = User.first
        #         end
        #
        #         should "return its full name"
        #           assert_equal 'John Doe', @user.full_name
        #         end
        #       end
        #     end
        #
        # This code will produce the method `"test: A User instance should
        # return its full name. "`.
        #
        # Contexts may be nested. Nested contexts run their `setup` blocks from
        # out to in before each `should` statement. They then run their
        # `teardown` blocks from in to out after each `should` statement.
        #
        #     class UserTest < Minitest::Test
        #       context "A User instance" do
        #         setup do
        #           @user = User.first
        #         end
        #
        #         should "return its full name"
        #           assert_equal 'John Doe', @user.full_name
        #         end
        #
        #         context "with a profile" do
        #           setup do
        #             @user.profile = Profile.first
        #           end
        #
        #           should "return true when sent :has_profile?"
        #             assert @user.has_profile?
        #           end
        #         end
        #       end
        #     end
        #
        # This code will produce the following methods:
        #
        # * `"test: A User instance should return its full name. "`
        # * `"test: A User instance with a profile should return true when sent :has_profile?. "`
        #
        # **Just like `should` statements, a `context` block can exist next to
        # normal `def test_the_old_way; end` tests.** This means you do not have
        # to fully commit to the `context`/`should` syntax in a test file.
        #
        # @return [Shoulda::Context::Context]
        #
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
        #     class UserTest < Minitest::Test
        #       described_type  # => User
        #     end
        #
        def described_type
          @described_type ||= self.name.
            gsub(/Test$/, '').
            split('::').
            inject(Object) do |parent, local_name|
              parent.const_get(local_name, false)
            end
        end

        # When using `should` or `should_not` with a matcher, allows you to set
        # the object that the matcher will run against.
        #
        # For instance, this code:
        #
        #     class UserTest < Minitest::Test
        #       subject { User.first }
        #
        #       should validate_uniqueness_of(:email)
        #     end
        #
        # is essentially equivalent to:
        #
        #     class UserTest < Minitest::Test
        #       def test_uniqueness
        #         assert_accepts validate_uniqueness_of(:email), User.first
        #       end
        #     end
        #
        # which is equivalent to:
        #
        #     class UserTest < Minitest::Test
        #       def test_uniqueness
        #         matcher = validate_uniqueness_of(:email)
        #         assert matcher.matches?(User.first), matcher.failure_message
        #       end
        #     end
        #
        # The difference between this and the old-style `test_*` method is that
        # setting the `subject` configures the behavior for multiple matchers,
        # not just one at a time:
        #
        #     class UserTest < Minitest::Test
        #       subject { User.first }
        #
        #       should validate_presence_of(:name)
        #       should validate_presence_of(:email)
        #       should validate_uniqueness_of(:email)
        #     end
        #
        def subject(&block)
          @subject_block = block
        end

        # @private
        def subject_block
          @subject_block ||= nil
        end
      end

      module InstanceMethods
        # Returns an instance of the class under test.
        #
        #     class UserTest < Minitest::Test
        #       should "be a user" do
        #         assert_kind_of User, subject  # passes
        #       end
        #     end
        #
        # The subject can be explicitly set using the `subject` class method:
        #
        #     class UserTest < Minitest::Test
        #       subject { User.first }
        #
        #       should "be an existing user" do
        #         assert !subject.new_record?  # uses the first user
        #       end
        #     end
        #
        # The subject is used by all macros that require an instance of the
        # class being tested.
        #
        def subject
          @shoulda_subject ||= construct_subject
        end

        # @private
        def subject_block
          (@shoulda_context && @shoulda_context.subject_block) || self.class.subject_block
        end

        # @private
        def get_instance_of(object_or_klass)
          if object_or_klass.is_a?(Class)
            object_or_klass.new
          else
            object_or_klass
          end
        end

        # @private
        def instance_variable_name_for(klass)
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
    end
  end
end
