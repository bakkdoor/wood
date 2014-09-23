class MyIndentedPrinter
  include Wood::IndentedPrinter
  attr_accessor :io, :indentation
  def initialize(indentation = 2)
    @io = StringIO.new
    @indentation = indentation
  end

  def output
    @io.string
  end
end

describe Wood::IndentedPrinter do
  before :each do
    @p = MyIndentedPrinter.new
  end

  it "starts out with indentation = 0" do
    @p.print "Hello"
    @p.output.should == "Hello"
  end

  it "indents by the given amount" do
    @p.print "Hello"
    @p.with_indentation {
      @p.print "World"
    }
    @p.output.should == "Hello\n  World\n"
  end

  it "indents by a specific indentation" do
    @p.indentation = 5
    @p.print "Hello"
    @p.with_indentation {
      @p.print "yo"
      @p.newline
      @p.print "done"
    }
    @p.output.should == "Hello\n     yo\n     done\n"
  end

  it "indents and unindents the output explicitly" do
    @p.print "ok"
    @p.indent
    @p.newline
    @p.print "what"
    @p.unindent
    @p.newline
    @p.print "done"

    @p.output.should == "ok\n  what\ndone"
  end

  it "prints followed by a newline" do
    @p.println "start"
    @p.println "done"

    @p.output.should == "start\ndone\n"
  end
end
