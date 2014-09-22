class MyVisitor
  include Forest::NodeVisitor

  ignore_nodes :node_c, :node_d

  attr_reader :value

  def node_a(node)
    @value = "in node_a"
  end

  def node_b(node)
    @value = "in node_b"
  end
end

describe Forest::NodeVisitor do
  before :each do
    @v = MyVisitor.new
    @node = Struct.new(:node_name)
  end

  it "dispatches based on node_name" do
    a = @node.new("node_a")
    b = @node.new("node_b")

    @v.visit(a)
    @v.value.should == "in node_a"
    @v.visit(b)
    @v.value.should == "in node_b"
  end

  it "raises an exception when trying to visit an undefined node" do
    expect {
      @v.visit @node.new("foo")
    }.to raise_error(NoMethodError)
  end

  it "ignores specified nodes" do
    @v.visit(@node.new("node_c")).ignored.should be_truthy
    @v.visit(@node.new("node_d")).ignored.should be_truthy
  end
end
