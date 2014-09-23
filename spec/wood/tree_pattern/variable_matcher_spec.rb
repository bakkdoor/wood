describe Wood::TreePattern::VariableMatcher do
  before :each do
    @pb = Wood::TreePattern::PatternBuilder.new
    @vm = Wood::TreePattern::VariableMatcher.new(@pb, :var_name)
  end

  it "matches any node and adds a corresponding var to its PatternBuilder" do
    @pb.vars.should be_empty
    @vm.should === IntLiteral[10] # do the match
    @pb.vars.should_not be_empty

    @pb.vars.first.tap do |var|
      var.name.should == :var_name
      var.value.should == IntLiteral[10]
    end
  end

  it "equal to any node" do
    @vm.should == IntLiteral[10]
    @vm.should == StringLiteral["foo"]
    @vm.should == @vm
  end

  it "returns a sexp notation" do
    @vm.sexp.should == [:variable_matcher, :var_name]
  end

  it "returns a string notation of self" do
    @vm.inspect.should == @vm.sexp.inspect
  end

  it "returns a TypeMatcher based on self" do
    tm = @vm.with_type(Wood::Types::Int)
    tm.node_pattern.should == @vm
    tm.type_pattern.should == Wood::Types::Int
  end
end
