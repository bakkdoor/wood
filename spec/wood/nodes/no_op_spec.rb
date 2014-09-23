describe Wood::Nodes::NoOp do
  it "has type void" do
    Wood::Nodes::NoOp[].type.should == Wood::Types::Void
  end
end
