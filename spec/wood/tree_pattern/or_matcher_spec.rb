describe Wood::TreePattern::OrMatcher do
  OrMatcher = Wood::TreePattern::OrMatcher

  it "matches either a or b but not c" do
    a = Operator[name: :*, left: IntLiteral[10], right: IntLiteral[0]]
    b = Operator[name: :*, left: IntLiteral[2], right: IntLiteral[3]]
    c = Operator[name: :+, left: a, right: b]
    om = OrMatcher.new(a, b)

    om.should === a
    om.should === b
    om.should_not === c
  end

  it "is equal to a or b" do
    a = Operator[name: :*, left: IntLiteral[3], right: IntLiteral[2]]
    b = Operator[name: :+, left: IntLiteral[5], right: IntLiteral[4]]
    c = Operator[name: :+, left: IntLiteral[1], right: IntLiteral[2]]

    om = OrMatcher.new(a, b)

    om.should == a
    om.should == b

    om.should_not == c
  end

  context "debugging output" do
    before do
      @a = Operator[name: :*, left: IntLiteral[3], right: IntLiteral[2]]
      @b = Null[]
    end

    it "returns a sexp" do
      OrMatcher.new(@a, @b).sexp.should == [:or_matcher, @a.sexp, @b.sexp]
    end

    it "returns an inspect string" do
      om = OrMatcher.new(@a, @b)
      om.inspect.should == om.sexp.inspect
    end
  end
end
