module Shoulda
  module Context
    module Assertions
      # Asserts that two arrays contain the same elements, the same number of
      # times. (Essentially `==`, but unordered.)
      #
      # @param a1 [Array] The expected array.
      # @param a2 [Array] The actual array.
      # @param msg [String] An optional message.
      #
      # @example
      #   assert_same_elements([:a, :b, :c], [:a, :b, :c])  #=> passes
      #   assert_same_elements([:a, :b, :c], [:c, :a, :b])  #=> passes
      #   assert_same_elements([:a, :b, :c], [:c, :d, :b])  #=> fails
      #
      # @raise [Minitest::Assertion, Test::Unit::AssertionFailedError]
      # @return [void]
      def assert_same_elements(a1, a2, msg = nil)
        [:select, :inject, :size].each do |m|
          [a1, a2].each {|a| assert_respond_to(a, m, "Are you sure that #{a.inspect} is an array?  It doesn't respond to #{m}.") }
        end

        assert a1h = a1.inject({}) { |h,e| h[e] ||= a1.select { |i| i == e }.size; h }
        assert a2h = a2.inject({}) { |h,e| h[e] ||= a2.select { |i| i == e }.size; h }

        assert_equal(a1h, a2h, msg)
      end

      # Asserts that a collection contains an element.
      #
      # @param collection [Array]
      # @param x [String, Regexp] If a string, ensures that the collection
      #   contains `x`; if a regex, ensures that at least one element from the
      #   collection matches `x`.
      # @param extra_msg [String] An optional message.
      #
      # @example
      #   assert_contains(['a', '1'], 'a')          #=> passes
      #   assert_contains(['a', '1'], /\d/)         #=> passes
      #   assert_contains(['a', '1'], /not there/)  #=> fails
      #
      # @raise [Minitest::Assertion, Test::Unit::AssertionFailedError]
      # @return [void]
      def assert_contains(collection, x, extra_msg = "")
        collection = Array(collection)
        msg = "#{x.inspect} not found in #{collection.to_a.inspect} #{extra_msg}"
        case x
        when Regexp
          assert(collection.detect { |e| e =~ x }, msg)
        else
          assert(collection.include?(x), msg)
        end
      end

      # Asserts that a collection does not contain an element.
      #
      # @param collection [Array]
      # @param x [String, Regexp] If a string, ensures that the collection
      #   contains `x`; if a regex, ensures that none of the elements from the
      #   collection match `x`.
      # @param extra_msg [String] An optional message.
      #
      # @example
      #   assert_does_not_contain(['a', '1'], 'a')          #=> fails
      #   assert_does_not_contain(['a', '1'], /\d/)         #=> fails
      #   assert_does_not_contain(['a', '1'], /not there/)  #=> passes
      #
      # @raise [Minitest::Assertion, Test::Unit::AssertionFailedError]
      # @return [void]
      def assert_does_not_contain(collection, x, extra_msg = "")
        collection = Array(collection)
        msg = "#{x.inspect} found in #{collection.to_a.inspect} " + extra_msg
        case x
        when Regexp
          assert(!collection.detect { |e| e =~ x }, msg)
        else
          assert(!collection.include?(x), msg)
        end
      end

      # Asserts that a matcher passes (i.e. its `matches?` method returns true)
      # when run with the `target`.
      #
      # @param matcher [#matches?] An object that conforms to RSpec 3's matcher
      #   API.
      # @param target [any] The argument that will get passed to `matches?`
      # @param options [Hash]
      # @option :message [String] The negative failure message that the matcher
      #   should produce, in the event that it passes.
      # @return [void]
      def assert_accepts(matcher, target, options = {})
        if matcher.respond_to?(:in_context)
          matcher.in_context(self)
        end

        if matcher.matches?(target)
          safe_assert_block { true }
          if options[:message]
            assert_match options[:message], matcher.failure_message_when_negated
          end
        else
          safe_assert_block(matcher.failure_message) { false }
        end
      end

      # Asserts that a matcher fails (i.e. its `matches?` method returns false
      # or its `does_not_match?` method returns true) when run with the
      # `target`.
      #
      # @param matcher [#matches?] An object that conforms to RSpec 3's matcher
      #   API.
      # @param target [any] The argument that will get passed to `matches?`
      # @param options [Hash]
      # @option :message [String] The positive failure message that the matcher
      #   should produce, in the event that it passes.
      # @return [void]
      def assert_rejects(matcher, target, options = {})
        if matcher.respond_to?(:in_context)
          matcher.in_context(self)
        end

        not_match =
          if matcher.respond_to?(:does_not_match?)
            matcher.does_not_match?(target)
          else
            !matcher.matches?(target)
          end

        if not_match
          safe_assert_block { true }
          if options[:message]
            assert_match options[:message], matcher.failure_message
          end
        else
          safe_assert_block(matcher.failure_message_when_negated) { false }
        end
      end

      # @private
      def safe_assert_block(message = "assert_block failed.", &block)
        if respond_to?(:assert_block)
          assert_block message, &block
        else
          assert yield, message
        end
      end
    end
  end
end
