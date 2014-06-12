describe Forest::TreePattern::TypeMatcher do#
  context "match certain node pattern and type pattern" do
    before do
      @m = Forest::TreePattern::TypeMatcher[
        node: Variable::Reference,
        type: Forest::Types::U8
      ]
      @m2 = Variable::Reference.with_type(Forest::Types::U8)
    end

    it "matches the right nodes" do
      [
        Variable::Reference[name: :foo, type: Forest::Types::U8],
        Variable::Reference[name: :bar, type: Forest::Types::U8]
      ].each do |node|
        @m.should === node
        @m2.should === node
      end
    end

    it "doesn't match the wrong nodes" do
      [
        Variable::Reference[name: :foo, type: Forest::Types::Char],
        Variable::Reference[name: :bar, type: Forest::Types::Int],
        Variable::Declaration[],
        NoOp[]
      ].each do |node|
        @m.should_not === node
        @m.should_not == node
        @m2.should_not === node
        @m2.should_not == node
      end
    end
  end

  context "match any node pattern and certain type pattern" do
    before do
      @type = Forest::Types::Array[Forest::Types::Int]
      @m = Forest::TreePattern::TypeMatcher[type: @type]
      @m2 = Node.with_type(@type)
    end

    it "matches the right nodes" do
      [
        Function::Declaration[type: @type, name: :foo],
        Return[type: @type, expression: Variable::Reference[name: :bar]],
        Variable::Reference[type: @type, name: :baz]
      ].each do |node|
        @m.should === node
        @m.should == node
        @m2.should === node
        @m2.should_not == node
      end
    end

    it "doesn't match the wrong nodes" do
      [
        Function::Declaration[type: Forest::Types::Int, name: :foo],
        Return[type: Forest::Types::Int, expression: Variable::Reference[name: :bar]],
        Variable::Reference[type: Forest::Types::Int, name: :baz]
      ].each do |node|
        @m.should_not === node
        @m.should_not == node
        @m2.should_not === node
        @m2.should_not == node
      end
    end
  end
end
