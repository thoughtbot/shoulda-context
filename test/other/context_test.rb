require File.join(File.dirname(__FILE__), '..', 'test_helper')

class ContextTest < Test::Unit::TestCase # :nodoc:
  
  context "context with setup block" do
    setup do
      @blah = "blah"
    end
    
    should "have @blah == 'blah'" do
      assert_equal "blah", @blah
    end
    
    should "have name set right" do
      assert_match(/^test: context with setup block/, self.to_s)
    end

    context "and a subcontext" do
      setup do
        @blah = "#{@blah} twice"
      end
      
      should "be named correctly" do
        assert_match(/^test: context with setup block and a subcontext should be named correctly/, self.to_s)
      end
      
      should "run the setup methods in order" do
        assert_equal @blah, "blah twice"
      end
    end
  end

  context "another context with setup block" do
    setup do
      @blah = "foo"
    end
    
    should "have @blah == 'foo'" do
      assert_equal "foo", @blah
    end

    should "have name set right" do
      assert_match(/^test: another context with setup block/, self.to_s)
    end
  end
  
  context "context with method definition" do
    setup do
      def hello; "hi"; end
    end
    
    should "be able to read that method" do
      assert_equal "hi", hello
    end

    should "have name set right" do
      assert_match(/^test: context with method definition/, self.to_s)
    end
  end
  
  context "another context" do
    should "not define @blah" do
      assert_nil @blah
    end
  end
    
  context "context with multiple setups and/or teardowns" do
    
    cleanup_count = 0
        
    2.times do |i|
      setup { cleanup_count += 1 }
      teardown { cleanup_count -= 1 }
    end
    
    2.times do |i|
      should "call all setups and all teardowns (check ##{i + 1})" do
        assert_equal 2, cleanup_count
      end
    end
    
    context "subcontexts" do
      
      2.times do |i|
        setup { cleanup_count += 1 }
        teardown { cleanup_count -= 1 }
      end
                  
      2.times do |i|
        should "also call all setups and all teardowns in parent and subcontext (check ##{i + 1})" do
          assert_equal 4, cleanup_count
        end
      end
      
    end
    
  end
  
  should_eventually "should pass, since it's unimplemented" do
    flunk "what?"
  end
  
  should_eventually "should not require a block when using should_eventually"
  should "should pass without a block, as that causes it to piggyback to should_eventually"
end
