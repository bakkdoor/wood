describe Forest::Nodes::CodeBlock do
  it "defaults to an empty array of expressions" do
    CodeBlock[].expressions.should be_empty
    CodeBlock[].should be_empty
    CodeBlock[].empty?.should be_truthy
  end

  it "behaves as an Enumerable and forward delegates #each" do
    expressions = [
      Function::Call[name: :foo],
      Function::Call[name: :bar],
      Return[]
    ]
    cb = CodeBlock[expressions: expressions]
    cb.to_a.should == expressions
    expressions.size.times do |i|
      cb[i].should == expressions[i]
    end
    cb << Function::Call[name: :final]
    cb.size.should == 4
    cb[-1].should == Function::Call[name: :final]
  end

  it "returns an array of the body's sexps" do
    expressions = [
      Function::Call[name: :foo],
      Function::Call[name: :bar],
      Return[]
    ]
    CodeBlock[expressions: expressions].sexp.should == expressions.map(&:sexp)
  end
end
