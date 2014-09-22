describe Forest::Nodes::Operator do
  Operator = Forest::Nodes::Operator

  it "is boolean" do
    Operator::BOOL_OPS.each do |name|
      Operator[name: name].boolean?.should be_truthy
    end
  end

  it "it is not boolean" do
    Operator::NON_BOOL_OPS.each do |name|
      Operator[name: name].boolean?.should be_falsey
    end
  end

  it "returns itself as a boolean operator" do
    Operator::NON_BOOL_OPS.each do |name|
      op = Operator[name: name]
      op.to_boolean.should == Operator[
        name: :"!=",
        left: op,
        right: IntLiteral[0]
      ]
    end

    Operator::BOOL_OPS.each do |name|
      op = Operator[name: name]
      op.to_boolean.should == op
    end
  end
end
