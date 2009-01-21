require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/code_parser'
require 'reek/report'
require 'reek/smells/large_class'

include Reek
include Reek::Smells

describe LargeClass do

  class BigOne
    26.times do |i|
      define_method "method#{i}".to_sym do
        @melting
      end
    end
  end

  before(:each) do
    @rpt = Report.new
    @cchk = CodeParser.new(@rpt, Reek::smell_listeners)
  end

  it 'should not report short class' do
    class ShortClass
      def method1() @var1; end
      def method2() @var2; end
      def method3() @var3; end
      def method4() @var4; end
      def method5() @var5; end
      def method6() @var6; end
    end
    @cchk.check_object(ShortClass)
    @rpt.should be_empty
  end

  it 'should report large class' do
    @cchk.check_object(BigOne)
    @rpt.length.should == 1
  end

  it 'should report class name' do
    @cchk.check_object(BigOne)
    @rpt[0].report.should match(/BigOne/)
  end

  describe 'when exceptions are listed' do
    before :each do
      @ctx = ClassContext.new(StopContext.new, [0, :Humungous])
      30.times { |num| @ctx.record_method("method#{num}") }
    end

    it 'should ignore first excepted name' do
      lc = LargeClass.new({'exceptions' => ['Humungous']})
      lc.examine(@ctx, @rpt).should == false
      @rpt.length.should == 0
    end

    it 'should ignore second excepted name' do
      lc = LargeClass.new({'exceptions' => ['Oversized', 'Humungous']})
      lc.examine(@ctx, @rpt).should == false
      @rpt.length.should == 0
    end

    it 'should report non-excepted name' do
      lc = LargeClass.new({'exceptions' => ['SmellMe']})
      lc.examine(@ctx, @rpt).should == true
      @rpt.length.should == 1
    end
  end
end
