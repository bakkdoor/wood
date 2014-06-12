describe Forest::TreePattern::NodeFinder do
  before do
    @nf = Forest::TreePattern::NodeFinder.new
  end

  it "finds a node up the tree" do
    ast = WhileLoop[
      condition: TrueLiteral[],
      body: CodeBlock[
        IfElse[
          condition: Operator[
            name: :<,
            left: Variable::Reference[:x],
            right: IntLiteral[10]
          ],
          then_branch: CodeBlock[Return[CharLiteral["a"]]],
          else_branch: CodeBlock[Return[CharLiteral["b"]]]
        ]
      ]
    ]

    @nf.ast = ast.body.first.else_branch.first
    @nf.find_parent_node(WhileLoop).should == ast
    @nf.find_parent_node(IfElse).should == ast.body.first
    @nf.find_parent_node(Operator).should be_nil
    @nf.find_parent_node(Function::Call).should be_nil
    @nf.find_parent_node(Return).should be_nil
  end

  it "finds multiple nodes up the tree" do
    ast = WhileLoop[
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
              value: Function::Call[name: :foo, args: [Variable::Reference[:z]]]
            ]
          ]
        ]
      ]
    ]

    @nf.ast = ast.body[1].body.first
    @nf.find_parent_nodes(WhileLoop).should == [ast.body[1], ast]
    @nf.find_parent_nodes(Function::Declaration).should == []
    @nf.find_parent_nodes(Assignment).should == []
  end

  it "finds a node down the tree" do
    ast = WhileLoop[
      condition: Variable::Reference[:x],
      body: CodeBlock[
        Switch[
          expression: Variable::Reference[:x],
          cases: [
            Switch::Case[
              expression: Variable::Reference[:FOO_1],
              body: CodeBlock[Return[StringLiteral["foo1"]]]
            ],
            Switch::Case[
              expression: Variable::Reference[:FOO_2],
              body: CodeBlock[Return[StringLiteral["foo2"]]]
            ],
            Switch::Case[
              expression: Variable::Reference[:FOO_3],
              body: CodeBlock[Return[StringLiteral["foo3"]]]
            ],
            Switch::DefaultCase[
              body: CodeBlock[Return[Variable::Reference[:x]]]
            ]
          ]
        ]
      ]
    ]

    switch = ast.body.first
    @nf.ast = ast

    @nf.find_child_node(Switch).should == switch
    @nf.find_child_node(Switch::Case).should == switch.cases.first
    @nf.find_child_node(Switch::DefaultCase).should == switch.cases[3]
    @nf.find_child_nodes(IfElse).should == []

    @nf.find_child_nodes(Switch::Case).should ==
      switch.cases.grep(Switch::Case)
    @nf.find_child_nodes(Return).should ==
      switch.cases.map{|c| c.body.first }.grep(Return)
  end
end
