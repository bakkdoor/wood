describe Forest::TreePattern::Matcher do
  it "matches any node" do
    class MatchAll
      include Forest::TreePattern::Matcher
      pattern { _ }
    end

    MatchAll.pattern_builders.should_not be_empty

    m = MatchAll.new
    m.should === Operator[
      name: :*,
      left: IntLiteral[3],
      right: IntLiteral[2]
    ]
  end

  it "matches string literal nodes" do
    class MatchString
      include Forest::TreePattern::Matcher
      pattern {
        StringLiteral[val]
      }
    end

    m = MatchString.new
    m.should === StringLiteral["Hello, World!"]
  end

  it "matches a specific int literal node" do
    class MatchIntLit3
      include Forest::TreePattern::Matcher
      pattern {
        IntLiteral[3]
      }
    end

    m = MatchIntLit3.new
    m.should === IntLiteral[3]
    m.should_not === IntLiteral[4]
  end

  it "rewrites a int literal to a string literal node" do
    class RewriteIntLiteral
      include Forest::TreePattern::Matcher
      pattern {
        IntLiteral[val]
      }.rewrite {
        StringLiteral[val.to_s]
      }
    end

    rw = RewriteIntLiteral.new
    rw.replacement_for(IntLiteral[10]).should == StringLiteral["10"]
  end

  it "rewrites a nested node" do
    class RewriteNestedNode
      include Forest::TreePattern::Matcher
      pattern {
        Operator[
          name: :*,
          left: left,
          right: IntLiteral[10]
        ]
      }.rewrite {
        Operator[
          name: :*,
          left: left,
          right: IntLiteral[100]
        ]
      }
    end

    rw = RewriteNestedNode.new
    # no change if no match:
    rw.replacement_for(StringLiteral[10]).should == StringLiteral[10]

    1.upto(10).each do |i|
      original    = Operator[name: :*, left: IntLiteral[i], right: IntLiteral[10]]
      replacement = Operator[name: :*, left: IntLiteral[i], right: IntLiteral[100]]

      rw.replacement_for(original).should == replacement
    end
  end

  it "defines VariableMatchers via method_missing" do
    class VarMatcherWithMethodMissing
      include Forest::TreePattern::Matcher
      pattern {
        StringLiteral[val]
      }.rewrite {
        StringLiteral[val * 2]
      }
    end

    VarMatcherWithMethodMissing.new.replacement_for(StringLiteral["foo"]).should == StringLiteral["foofoo"]
  end

  it "defines VariableMatchers via _" do
    class VarMatcherWith_
      include Forest::TreePattern::Matcher
      pattern {
        StringLiteral[_(:val)]
      }.rewrite {
        StringLiteral[val * 2]
      }
    end

    VarMatcherWith_.new.replacement_for(StringLiteral["foo"]).should == StringLiteral["foofoo"]
  end

  it "returns the node itself if no ReplacementBuilder has been defined" do
    class NoReplacement
      include Forest::TreePattern::Matcher
      pattern { StringLiteral[val] }
    end

    sl = StringLiteral["foo"]
    nr = NoReplacement.new

    nr.should === sl
    nr.replacement_for(sl).should == sl
  end

  it "returns a matched child node" do
    class ChildNodeReplacement
      include Forest::TreePattern::Matcher
      pattern {
        Operator[name: :*, left: left, right: _]
      }.rewrite {
        left
      }
    end

    left = Operator[name: :+, left: IntLiteral[10], right: IntLiteral[42]]
    op = Operator[name: :*, left: left, right: IntLiteral[10]]
    ChildNodeReplacement.new.replacement_for(op).should == left
  end

  it "has node defined (apart from variables) in the rewrite block" do
    class NodeDefinedInRewrite
      include Forest::TreePattern::Matcher
      pattern {
        StringLiteral["foo"]
      }.rewrite {
        node.should == StringLiteral["foo"]
        StringLiteral["bar"]
      }
    end

    match    = StringLiteral["foo"]
    no_match = StringLiteral["nope"]
    NodeDefinedInRewrite.new.replacement_for(match).should == StringLiteral["bar"]
    NodeDefinedInRewrite.new.replacement_for(no_match).should == no_match
    NodeDefinedInRewrite.new.should === match
    NodeDefinedInRewrite.new.should_not === no_match
  end

  it "calls a block if a pattern is matched" do
    MatchedNodes = []
    class CallBlockMatcher
      include Forest::TreePattern::Matcher
      pattern {
        StringLiteral["foo"]
      }.perform {
        MatchedNodes << node
      }

      pattern {
        Operator[name: :*, left: IntLiteral[left], right: IntLiteral[right]]
      }.perform {
        MatchedNodes << IntLiteral[left * right]
      }
    end

    cbm = CallBlockMatcher.new

    MatchedNodes.should be_empty

    cbm.should === StringLiteral["foo"]
    MatchedNodes.should == [StringLiteral["foo"]]

    cbm.should_not === StringLiteral["foobar"]
    MatchedNodes.should == [StringLiteral["foo"]]

    cbm.should === Operator[
      name: :*,
      left: IntLiteral[2],
      right: IntLiteral[3]
    ]
    MatchedNodes.should == [
      StringLiteral["foo"], IntLiteral[6]
    ]
  end

  it "names the root node in a pattern" do
    class MyRootNodeMatcher
      include Forest::TreePattern::Matcher
      pattern {
        my_string StringLiteral[val]
      }.perform {
        my_string.should       == node
        my_string.value.should == node.value
        my_string.value.should == val
      }
    end

    MyRootNodeMatcher.new.should === StringLiteral["foo"]
  end

  it "names child nodes in a nested pattern" do
    class MyNestedNodeMatcher
      include Forest::TreePattern::Matcher
      pattern {
        Operator[
          name: opname,
          left: outer_left(Operator[
            name: :*,
            left: inner_left(Operator[
              name: _,
              left: IntLiteral[_],
              right: IntLiteral[_]
            ]),
            right: inner_right(_)
          ]),
          right: outer_right(IntLiteral[42])
        ]
      }.perform {
        opname.should      == node.name
        outer_left.should  == node.left
        outer_right.should == node.right
        inner_left.should  == node.left.left
        inner_right.should == node.left.right
      }
    end

    MyNestedNodeMatcher.new.should === Operator[
      name: :+,
      left: Operator[
        name: :*,
        left: Operator[
          name: :+,
          left: IntLiteral[3],
          right: IntLiteral[5]
        ],
        right: IntLiteral[2]
      ],
      right: IntLiteral[42]
    ]
  end

  it "matches a nested node via a within-pattern" do
    MatchedInts = []
    class MyWithinMatcher
      include Forest::TreePattern::Matcher
      pattern {
        CodeBlock
      }.perform {
        within(node) {
          pattern {
            IntLiteral[v]
          }.perform {
            MatchedInts << v
          }
        }
      }
    end

    m = MyWithinMatcher.new
    m.should === CodeBlock[
      expressions: [
        StringLiteral["foo"],
        IntLiteral[10],
        FloatLiteral[1.5],
        IntLiteral[100]
      ]
    ]
    MatchedInts.should == [10, 100]
  end

  it "matches nodes with a given type" do
    MyType = Struct.new(:name).new(:my_type)
    class MyTypedMatcher
      include Forest::TreePattern::Matcher
      pattern {
        Variable::Reference.with_type Forest::Types::Array[MyType]
      }.perform {
        node.type = MyType
      }

      pattern {
        Variable::Reference[name: /foo_(\d+)/].with_type(Forest::Types::U8)
      }.perform {
        node.name = :"__gen__#{node.name}"
      }
    end

    m = MyTypedMatcher.new
    ref = Variable::Reference[
      name: :foo,
      type: Forest::Types::Array[MyType]
    ]

    m.should === ref
    ref.type.should == MyType

    ref = Variable::Reference[
      name: :foo_123,
      type: Forest::Types::U8
    ]

    m.should === ref
    ref.name.should == :__gen__foo_123
  end
end
