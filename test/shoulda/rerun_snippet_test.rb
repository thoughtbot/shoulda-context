require "test_helper"

class RerunSnippetTest < PARENT_TEST_CASE
  context "A Rails application with shoulda-context added to it" do
    should "display the correct rerun snippet when a test fails" do
      if app.rails_version >= 5 && TEST_FRAMEWORK == "minitest"
        app.create

        app.write_file("test/models/failing_test.rb", <<~RUBY)
          ENV["RAILS_ENV"] = "test"
          require_relative "../../config/environment"

          class FailingTest < #{PARENT_TEST_CASE}
            should "fail" do
              assert false
            end
          end
        RUBY

        command_runner = app.run_n_unit_test_suite

        assert_includes(
          command_runner.output,
          "bin/rails test test/models/failing_test.rb:5"
        )
      end
    end
  end

  def app
    @_app ||= RailsApplicationWithShouldaContext.new
  end
end
