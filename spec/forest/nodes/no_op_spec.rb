describe Forest::Nodes::NoOp do
  it "has type void" do
    Forest::Nodes::NoOp[].type.should == Forest::Types::Void
  end
end
