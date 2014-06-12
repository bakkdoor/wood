class MyNode < Node
  child_nodes :a, :b, :c
end

include Forest::Nodes

describe Node do
  it "has no default child nodes" do
    Node.__child_nodes__.should == []
  end

  it "includes the ClassMethods on subclasses" do
    MyNode.__child_nodes__.should == [:a, :b, :c]
    MyNode.node_name.should == :my_node
  end

  it "returns the correct node_name" do
    module MyModule
      class MyNode < Node
      end
    end

    MyNode.node_name.should == :my_node
    MyModule::MyNode.node_name.should == :my_module_my_node
  end

  it "provides a default sexp implementation" do
    class EmptyNode < Node
    end

    class ValueNode < Node
      child_nodes :value
      def sexp
        [:value_node, value]
      end
    end

    e = EmptyNode.new
    n = MyNode.new a: e, b: e, c: e
    n.sexp.should == [:my_node, [:empty_node], [:empty_node], [:empty_node]]

    n = MyNode.new a: e, b: ValueNode.new(value: "foo"), c: e
    n.sexp.should == [
      :my_node, [:empty_node], [:value_node, "foo"], [:empty_node]
    ]
  end

  it "compares nodes correctly for equality" do
    n1 = MyNode.new a: EmptyNode.new, b: MyNode.new, c: EmptyNode.new
    n2 = MyNode.new a: EmptyNode.new, b: MyNode.new, c: EmptyNode.new
    n3 = MyNode.new a: MyNode.new, b: EmptyNode.new, c: EmptyNode.new

    n1.should == n1
    n2.should == n2
    n3.should == n3

    n1.should == n2
    n2.should == n1

    n1.should_not == n3
    n2.should_not == n3

    n3.should_not == n1
    n3.should_not == n2
  end

  it "compares nodes correctly for matching" do
    any = Forest::TreePattern::AnyMatcher.new
    IntLiteral[10].should === IntLiteral[10]
    IntLiteral[10].should === IntLiteral[any]
    IntLiteral[any].should === IntLiteral[10]

    Operator[
      name: :*,
      left: any,
      right: any
    ].should === Operator[
      name: :*,
      left: IntLiteral[-10],
      right: IntLiteral[10]
    ]

    Operator[name: :*].should === Operator[
      name: :*,
      left: IntLiteral[10],
      right: IntLiteral[10]
    ]

    Operator[
      name: :*,
      left: IntLiteral[10],
      right: IntLiteral[10]
    ].should_not === Operator[name: :*]
  end

  it "supports node construction via Node##[]" do
    a = MyNode[a: EmptyNode[], b: MyNode[], c: EmptyNode[]]
    b = MyNode.new a: EmptyNode.new, b: MyNode.new, c: EmptyNode.new

    a.should == b
  end

  it "returns its child nodes" do
    node = MyNode[
      a: StringLiteral["foo"],
      b: IntLiteral[10],
      c: TrueLiteral.new
    ]

    node.child_nodes.should == [
      StringLiteral["foo"],
      IntLiteral[10],
      TrueLiteral.new
    ]

    MyNode.new.child_nodes.should == [nil, nil, nil]
  end

  it "returns the names of its child nodes" do
    MyNode.new.child_node_names.should == [:a, :b, :c]

    class EmptyNode < Node
    end
    EmptyNode.new.child_node_names.should be_empty
  end

  it "sets a child value" do
    n = MyNode[
      a: nil,
      b: IntLiteral[10],
      c: StringLiteral["foo"]
    ]
    n.set_child(:a, IntLiteral[42])
    n.should == MyNode[
      a: IntLiteral[42],
      b: IntLiteral[10],
      c: StringLiteral["foo"]
    ]
  end

  it "gets a child value" do
    n = MyNode[
      a: IntLiteral[42],
      b: IntLiteral[10],
      c: StringLiteral["foo"]
    ]
    n.get_child(:a).should == IntLiteral[42]
    n.get_child(:b).should == IntLiteral[10]
    n.get_child(:c).should == StringLiteral["foo"]
  end

  it "returns a default sexp implementation for basic ruby types" do
    :foo.sexp.should == :foo
    "foo".sexp.should == "foo"
    1.sexp.should == 1
    1.5.sexp.should == 1.5
    nil.sexp.should == nil
    true.sexp.should == true
    false.sexp.should == false
    [1,2,3].sexp.should == [1,2,3]
  end

  context "finds node up & down the tree" do
    before :each do
      @outer_while = WhileLoop[
        condition: Operator[
          name: :<,
          left: Variable::Reference[:x],
          right: Variable::Reference[:y]
        ],
        body: CodeBlock[
          Assignment[
            var: Variable::Reference[:x],
            value: Function::Call[name: :foo, args: [Variable::Reference[:y]]]
          ],
          WhileLoop[
            condition: Operator[
              name: :<,
              left: Variable::Reference[:y],
              right: Variable::Reference[:z]
            ],
            body: CodeBlock[
              Assignment[
                var: Variable::Reference[:y],
                value: Function::Call[name: :bar, args: [Variable::Reference[:z]]]
              ],
              Assignment[
                var: Variable::Reference[:z],
                value: IntLiteral[10]
              ]
            ]
          ]
        ]
      ]

      @x_assign    = @outer_while.body[0]
      @inner_while = @outer_while.body[1]
      @y_assign    = @inner_while.body[0]
      @z_assign    = @inner_while.body[1]
    end

    it "finds nodes up the tree" do
      @x_assign.find_parent_node(WhileLoop).should == @outer_while
      @y_assign.find_parent_node(WhileLoop).should == @inner_while
      @inner_while.find_parent_node(WhileLoop).should == @outer_while

      @x_assign.find_parent_nodes(WhileLoop).should == [@outer_while]
      @y_assign.find_parent_nodes(WhileLoop).should == [@inner_while, @outer_while]
      @inner_while.find_parent_nodes(WhileLoop).should == [@outer_while]

      @x_assign.find_parent_node(Assignment).should be_nil
      @y_assign.find_parent_node(Assignment).should be_nil
      @inner_while.find_parent_node(Assignment).should be_nil
    end

    it "finds nodes down the tree" do
      @outer_while.find_child_node(WhileLoop).should == @inner_while
      @outer_while.find_child_node(Assignment).should == @x_assign
      @inner_while.find_child_node(WhileLoop).should be_nil
      @inner_while.find_child_node(Assignment).should == @y_assign

      @outer_while.find_child_nodes(WhileLoop).should == [@inner_while]
      @outer_while.find_child_nodes(Assignment).should == [@x_assign, @y_assign, @z_assign]
      @inner_while.find_child_nodes(WhileLoop).should == []
      @inner_while.find_child_nodes(Assignment).should == [@y_assign, @z_assign]
    end

    it "deletes nodes down the tree" do
      @outer_while.delete_child_node(
        Assignment[
          var: Variable::Reference[name: :y],
          value: Function::Call[
            name: :bar,
            args: [ Variable::Reference[name: :z] ]
          ]
        ]
      ).should == @y_assign
      @inner_while.body.size.should == 1
      @inner_while.body[0].should   == @z_assign
    end

    it "deleted all child nodes that match down the tree" do
      any = Forest::TreePattern::AnyMatcher.new

      @outer_while.delete_child_nodes(
        Assignment[
          name: any,
          value: Function::Call[
            name: any,
            args: any
          ]
        ]
      ).should == [@x_assign, @y_assign]
      @inner_while.body.size.should == 1
      @inner_while.body[0].should   == @z_assign
    end
  end
end
