# Shoulda Context [![Gem Version][version-badge]][rubygems] [![Build Status][travis-badge]][travis] ![Downloads][downloads-badge] [![Hound][hound-badge]][hound]

[version-badge]: https://img.shields.io/gem/v/shoulda-context.svg
[rubygems]: https://rubygems.org/gems/shoulda-matchers
[travis-badge]: https://img.shields.io/travis/thoughtbot/shoulda-context/master.svg
[travis]: https://travis-ci.org/thoughtbot/shoulda-context
[downloads-badge]: https://img.shields.io/gem/dtv/shoulda-context.svg
[hound-badge]: https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg
[hound]: https://houndci.com

Shoulda Context makes it easy to write understandable and maintainable tests
under Minitest and Test::Unit within Rails projects or plain Ruby projects. It's
fully compatible with your existing tests and requires no retooling to use.

**[View the documentation for the latest version (1.2.2)][rubydocs] • [View
the changelog][changelog]**

[rubydocs]: http://thoughtbot.github.io/shoulda-context
[changelog]: CHANGELOG.md

## Overview

At a minimum, this gem provides some convenience layers around core Minitest or
Test::Unit functionality. Imagine some tests for a Calculator class:

```ruby
class CalculatorTest < Minitest::Test
  def setup
    @calculator = Calculator.new
  end

  def test_calculator_should_add_two_numbers_for_sum
    assert_equal 4, @calculator.sum(2, 2)
  end

  def test_calculator_should_multiply_two_numbers_for_product
    assert_equal 10, @calculator.product(2, 5)
  end
end
```

This looks nice, but typing `all_of_those_underscores` isn't fun. Plus, what if
you want to group tests together, say, by method? With Shoulda Context we can
write the following instead:

```ruby
class CalculatorTest < Minitest::Test
  context "Calculator" do
    setup do
      @calculator = Calculator.new
    end

    context "#sum" do
      should "add two numbers" do
        assert_equal 4, @calculator.sum(2, 2)
      end
    end

    context "#product" do
      should "multiply two numbers" do
        assert_equal 10, @calculator.product(2, 5)
      end
    end
  end
end
```

When run, this will produce the following test methods:

* `test_: Calculator #sum should add two numbers for the sum. `
* `test_: Calculator #sum should multiply two numbers for the product. `

Although making tests prettier helps, Shoulda Context really shines by making it
possible to make use of RSpec-compatible matchers to write extremely succinct
tests. For instance, with [Shoulda Matchers][shoulda-matchers], you can do this:

```ruby
class User < ActiveSupport::TestCase
  context "validations" do
    subject { FactoryBot.build(:user) }

    should validate_presence_of(:first_name)
    should validate_presence_of(:last_name)
    should validate_uniqueness_of(:email)
    should_not allow_value('weird').for(:email)
  end
end
```

[shoulda-matchers]: https://github.com/thoughtbot/shoulda-matchers

## Usage

### Writing basic tests

As we've seen above, `should` allows you to define tests:

``` ruby
class CarTest < Minitest::Test
  should "be able to drive" do
    car = Car.new
    assert car.respond_to?(:drive), "Car cannot drive"
  end
end
```

### Grouping together tests

Once you have a bunch of tests, you need a way to organize them. This is where
`context`s come into play. They allow you to specify scenarios or situations
that change the behavior of the object you're testing:

``` ruby
class CarTest < Minitest::Test
  context "when set to drive" do
    should "move forward" do
      car = Car.new
      car.mode = :drive
      assert_equal 15, car.speed
    end
  end

  context "when set to reverse" do
    should "move backward" do
      car = Car.new
      car.mode = :reverse
      assert_equal -15, car.speed
    end
  end
end
```

Because descriptions of contexts are combined with descriptions of tests when
those tests get run, it's common to wrap the whole test case in a context:

``` ruby
class CarTest < Minitest::Test
  context "A car" do
    context "when set to drive" do
      should "move forward" do
        car = Car.new
        car.mode = :drive
        assert_equal 15, car.speed
      end
    end

    context "when set to reverse" do
      should "move backward" do
        car = Car.new
        car.mode = :reverse
        assert_equal -15, car.speed
      end
    end
  end
end
```

Contexts can be arbitrarily nested to account for complex logic:

``` ruby
class CarTest < Minitest::Test
  context "A car" do
    context "when going more than 30 mph" do
      context "and manual override is disabled" do
        should "not be able to be set to first gear" do
          car = Car.new
          car.speed = 31
          refute car.set(gear: 1)
        end
      end

      context "and manual override is enabled" do
        should "be able to be set to first gear" do
          car = Car.new
          car.speed = 31
          car.manual_override = true
          assert car.set(gear: 1)
        end
      end
    end
  end
end
```

### Before and after

Sometimes you need a way to group together common actions that prepare a test to
be run, or clean things up after a test finishes. Since Shoulda Context provides
a DSL for specifying tests and grouping them together, it makes sense to do this
for setup and teardown as well. We call this `before` and `after`. It's worth
noting that to use this pair of methods, you'll need to be inside of a context:

``` ruby
class CustomerTest < Minitest::Test
  context "A customer" do
    before do
      @car = Rental.new
      @car.inspect
      @customer = Customer.new
    end

    after do
      @car.fill_gas
    end

    should "be able to rent a car" do
      @customer.rent(@car)
    end
  end
end
```

In this case, the `before` block gets run before the test and the `after` block
gets run afterward.

`before` and `after` hooks can be declared in any subcontext as well:

``` ruby
class TaskTest < Minitest::Test
  context "A task" do
    after do
      puts "clean kitchen"
    end

    context "if the robot is in the kitchen" do
      before do
        puts "place robot in kitchen"
      end

      context "and it is clean" do
        before do
          puts "yup, kitchen is clean"
        end

        context "and the robot has the right ingredients" do
          before do
            puts "obtain bread, peanut butter, and jelly"
          end

          after do
            puts "clear inventory"
          end

          should "make a sandwich" do
            puts "sandwich made"
          end

          should "eat the sandwich" do
            puts "sandwich eaten"
          end
        end
      end
    end
  end
end
```

`before` blocks are run outside-in before each test, and `after` blocks are run
inside-out after each test. So running these tests would spit out:

```
place robot in kitchen
yup, kitchen is clean
obtain bread, peanut butter, and jelly
sandwich made
clear inventory
clean kitchen
place robot in kitchen
yup, kitchen is clean
obtain bread, peanut butter, and jelly
sandwich eaten
clear inventory
clean kitchen
```

### Using matchers

If you have ever read any RSpec tests, you may have come across its concept of
matchers, which allows you to encapsulate and group together complex assertions
in a reusable package. With Shoulda Context you can use them in Minitest (or
Test::Unit) tests too!

For example, say that we have a series of models and we want to ensure they all
conform to a "Stateable" interface. We _could_ write a method like this:

``` ruby
def test_conforms_to_stateable
  instance = @model.new
  assert_respond_to instance, :current_state
  assert_respond_to instance, :current_state_updated_at
  assert_respond_to instance, :next_state
  assert_respond_to instance, :finished?
end
```

And we _could_ make a test case superclass and define a macro there that would
then in turn define this test:

``` ruby
class ModelTest < Minitest::Test
  protected

  def self.assert_conforms_to_stateable
    define_method :test_conforms_to_stateable do
      instance = @model.new
      assert_respond_to instance, :current_state
      assert_respond_to instance, :current_state_updated_at
      assert_respond_to instance, :next_state
      assert_respond_to instance, :finished?
    end
  end
end
```

And we _could_ use it like this:

``` ruby
class ProjectTest < ModelTest
  def setup
    @klass = Project
  end

  assert_conforms_to_stateable
end
```

But this is clunky and unshareable, and it doesn't produce a great error message
if it fails. Let's try making a matcher class instead:

``` ruby
class ConformToStateableMatcher
  METHOD_NAMES = [
    :current_state,
    :current_state_updated_at,
    :next_state,
    :finished?
  ]

  def matches?(klass)
    @klass = klass
    @instance = @klass.new
    unresponsive_methods.none?
  end

  def failure_message
    "Expected instance of #{@klass} to conform to Stateable. " +
    "However, it did not respond to: #{unresponsive_methods}"
  end

  private

  def unresponsive_methods
    METHOD_NAMES.select do |method_name|
      !@instance.respond_to?(method_name)
    end
  end
end
```

We'll add a class method to our superclass that returns an instance of the
matcher:

``` ruby
class ModelTest < Minitest::Test
  def self.conform_to_stateable
    ConformToStateableMatcher.new
  end
end
```

And now, instead of making use of a macro to apply our Stateable test, we can
say:

``` ruby
class ProjectTest < ModelTest
  context "A project" do
    subject { Project }

    should conform_to_stateable
  end
end
```

Isn't that lovely? Note how we provide the `subject` of the matcher in this
case; this is essential, as it's what will get fed into that matcher's
`matches?` method. (Otherwise, it would default to `Project.new`.)

To make use of this feature, it's worth noting that matchers must conform to
RSpec 3's matcher API. This means that a matcher you use or write must implement
these instance methods at a minimum:

* `matches?`
* `failure_message`
* `description`

It may also support these methods as well:

* `does_not_match?`
* `failure_message_when_negated`

### Assertions

In addition to the main API describe above, Shoulda Context also provides some
extra assertions that may be of use in your tests:

* `assert_same_elements` — compares two arrays for equality, but ignoring
  ordering
* `assert_contains` — asserts that an array has an item
* `assert_does_not_contain` — the opposite of `assert_contains`
* `assert_accepts` — what `should` uses internally; asserts that a matcher
  object matches against a value
* `assert_reject` — what `should_not` uses internally; asserts that a matcher
  object does not match against a value

### Note on running tests

Normally, you will run a single test like this:

    ruby -I lib path_to_test.rb -n test_does_something

When using Shoulda Context, however, you'll need to provide the full name of the
test, including a space at the end of the test name:

    ruby -I lib path_to_test.rb -n "test_: a calculator should add two numbers for the sum. "

## Compatibility

Shoulda Context is tested and supported against Rails 5.x, Rails 4.2, Minitest
5, Test::Unit 3, and Ruby 2.3+.

## Credits

Shoulda Context is maintained by [Travis Jeffery][travis-jeffery]. Thank you to
all the [contributors].

[travis-jeffery]: https://github.com/travisjeffery
[contributors]: https://github.com/thoughtbot/shoulda-context/contributors

## License

Shoulda Context is copyright © 2006-2019 [thoughtbot, inc][thoughtbot-website].
It is free software, and may be redistributed under the terms specified in the
[MIT-LICENSE](MIT-LICENSE) file.

[thoughtbot-website]: https://thoughtbot.com
