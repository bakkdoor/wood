describe Wood::TreePattern::AnyMatcher do
  before do
    @m = Wood::TreePattern::AnyMatcher.new
  end

  it "matches any node" do
    @m.should === Function::Call[name: :foo]
    @m.should === Variable::Declaration[
      name: :x,
      type: Wood::Types::Int,
      value: IntLiteral[10]
    ]
    @m.should === CharLiteral["c"]
    @m.should === IntLiteral[10]

    IntLiteral[@m].should === IntLiteral[10]
  end

  it "is equal to any node" do
    @m.should == IntLiteral[10]
    @m.should == StringLiteral["foo"]
    @m.should == @m
  end

  it "returns a sexp notation" do
    @m.sexp.should == [:any_matcher]
  end

  it "returns a string notation of self" do
    @m.inspect.should == @m.sexp.inspect
  end
end
