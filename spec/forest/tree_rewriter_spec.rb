describe Forest::TreeRewriter do
  it "rewrites nested nodes based on tree patterns" do
    class MyStringMatcher
      include Forest::TreePattern::Matcher
      pattern {
        StringLiteral[val]
      }.rewrite {
        StringLiteral[val * 2]
      }
    end

    class MultByZeroMatcher
      include Forest::TreePattern::Matcher
      ZERO = IntLiteral[0]

      pattern {
        Operator[name: :*, left: ZERO, right: _]
      }.rewrite {
        ZERO
      }

      pattern {
        Operator[name: :*, left: _, right: ZERO]
      }.rewrite {
        ZERO
      }
    end

    class MyTreeRewriter
      include Forest::TreeRewriter
      patterns MyStringMatcher.new, MultByZeroMatcher.new
    end

    tree = CodeBlock[
      Variable::Declaration[
        type: Forest::Types::Int,
        name: :x,
        init_val: Operator[
          name: :*,
          left: IntLiteral[0],
          right: IntLiteral[10]
        ]
      ],
      Variable::Declaration[
        type: Forest::Types::Int,
        name: :y,
        init_val: Operator[
          name: :*,
          left: IntLiteral[10],
          right: IntLiteral[0]
        ]
      ]
    ]
    rw = MyTreeRewriter.new
    rw.rewrite(tree)
    tree.should == CodeBlock[
      Variable::Declaration[
        type: Forest::Types::Int,
        name: :x,
        init_val: IntLiteral[0]
      ],
      Variable::Declaration[
        type: Forest::Types::Int,
        name: :y,
        init_val: IntLiteral[0]
      ]
    ]

    tree = Function::Declaration[
      name: :foo,
      type: Forest::Types::Int,
      body: CodeBlock[
        Variable::Declaration[
          type: Forest::Types::Int,
          name: :x,
          init_val: IntLiteral[2]
        ],
        Variable::Declaration[
          type: Forest::Types::Int,
          name: :y,
          init_val: Operator[
            name: :*,
            left: IntLiteral[2],
            right: Operator[
              name: :*,
              left: Variable::Reference[:x],
              right: IntLiteral[0]
            ]
          ]
        ],
        Variable::Declaration[
          type: Forest::Types::Int,
          name: :z,
          init_val: Operator[
            name: :*,
            left: IntLiteral[0],
            right: Variable::Reference[:x]
          ]
        ],
        Variable::Declaration[
          type: Forest::Types::String,
          name: :foo,
          init_val: StringLiteral["hello, world"]
        ]
      ]
    ]
    rw = MyTreeRewriter.new
    rw.rewrite(tree, false)

    rewritten_code = <<-C
    int foo() {
      int x = 2;
      int y = 0;
      int z = 0;
      char * foo = "hello, world!hello, world!";
    }
    C
    rewritten_code = Function::Declaration[
      name: :foo,
      type: Forest::Types::Int,
      body: CodeBlock[
        Variable::Declaration[
          type: Forest::Types::Int,
          name: :x,
          init_val: IntLiteral[2]
        ],
        Variable::Declaration[
          type: Forest::Types::Int,
          name: :y,
          init_val: IntLiteral[0]
        ],
        Variable::Declaration[
          type: Forest::Types::Int,
          name: :z,
          init_val: IntLiteral[0]
        ],
        Variable::Declaration[
          type: Forest::Types::String,
          name: :foo,
          init_val: StringLiteral["hello, world!hello, world!"]
        ]
      ]
    ]
    tree.should == rewritten_code
  end

  it "works with OrMatchers" do
    class MultByZeroOrRewriter
      include Forest::TreeRewriter
      include Forest::TreePattern::Matcher
      ZERO = IntLiteral[0]

      pattern {
        Operator[
          name: :*,
          left: ZERO,
          right: _
        ] | Operator[
          name: :*,
          left: _,
          right: ZERO
        ]
      }.rewrite {
        ZERO
      }

      pattern {
        Operator[
          name: :+,
          left: ZERO,
          right: val
        ] | Operator[
          name: :+,
          left: val,
          right: ZERO
        ]
      }.rewrite {
        val
      }

      patterns self.new
    end

    rw = MultByZeroOrRewriter.new
    tree = CodeBlock[
      Variable::Declaration[
        type: Forest::Types::Int,
        name: :x,
        init_val: Operator[
          name: :+,
          left: Operator[
            name: :*,
            left: IntLiteral[2],
            right: IntLiteral[3]
          ],
          right: Operator[
            name: :*,
            left: IntLiteral[2],
            right: IntLiteral[0]
          ]
        ]
      ]
    ]
    # call rewrite with repeated=false
    rw.rewrite(tree)
    tree.should == CodeBlock[
      Variable::Declaration[
        type: Forest::Types::Int,
        name: :x,
        init_val: Operator[
          name: :+,
          left: Operator[
            name: :*,
            left: IntLiteral[2],
            right: IntLiteral[3]
          ],
          right: IntLiteral[0]
        ]
      ]
    ]

    # rewrite again to apply second pattern rewrite
    rw.rewrite(tree)
    tree.should == CodeBlock[
      Variable::Declaration[
        type: Forest::Types::Int,
        name: :x,
        init_val: Operator[
          name: :*,
          left: IntLiteral[2],
          right: IntLiteral[3]
        ]
      ]
    ]

    # call rewrite with repeated=true (apply all rules in one run)
    tree = Variable::Declaration[
      type: Forest::Types::Int,
      name: :x,
      init_val: Operator[
        name: :+,
        left: Operator[
          name: :*,
          left: IntLiteral[2],
          right: IntLiteral[3]
        ],
        right: Operator[
          name: :*,
          left: IntLiteral[2],
          right: IntLiteral[0]
        ]
      ]
    ]
    rw.rewrite(tree, true)

    tree.should == Variable::Declaration[
      type: Forest::Types::Int,
      name: :x,
      init_val: Operator[
        name: :*,
        left: IntLiteral[2],
        right: IntLiteral[3]
      ]
    ]
  end

  it "rewrites the root node" do
    class MyRootRewriter
      include Forest::TreePattern::Matcher
      include Forest::TreeRewriter

      pattern {
        IfElse[
          condition: Operator[name: :<, left: _, right: _],
          then_branch: _
        ]
      }.perform {
        node.condition = TrueLiteral[]
        node.then_branch = CodeBlock[Return[StringLiteral["Hello, world!"]]]
      }

      patterns self.new
    end

    if_else = IfElse[
      condition: Operator[name: :<, left: IntLiteral[1], right: IntLiteral[2]],
      then_branch: CodeBlock[Return[StringLiteral["This should be rewritten"]]]
    ]

    MyRootRewriter.new.rewrite(if_else)

    if_else.condition.should == TrueLiteral[]
    if_else.then_branch.should == CodeBlock[Return[StringLiteral["Hello, world!"]]]
  end

  it "looks up parent nodes" do
    class MyParentNodeFinderRewriter
      include Forest::TreePattern::Matcher
      include Forest::TreeRewriter

      pattern {
        Assignment[var: ref, value: val]
      }.rewrite {
        if (wl = node.find_parent_node(WhileLoop)) && wl != node.parent_node
          case wl.condition
          when Assignment[var: ref]
            Function::Call[
              name: :triedToAssign,
              args: [
                StringLiteral[ref.name.to_s],
                val
              ]
            ]
          end
        end
      }

      patterns self.new
    end

    ast = WhileLoop[
      condition: Assignment[
        var: Variable::Reference[:x],
        value: Function::Call[name: :foo]
      ],
      body: CodeBlock[
        Assignment[
          var: Variable::Reference[:x],
          value: IntLiteral[10]
        ]
      ]
    ]

    MyParentNodeFinderRewriter.new.rewrite(ast)

    target = WhileLoop[
      condition: Assignment[
        var: Variable::Reference[:x],
        value: Function::Call[name: :foo]
      ],
      body: CodeBlock[
        Function::Call[
          name: :triedToAssign,
          args: [StringLiteral["x"], IntLiteral[10]]
        ]
      ]
    ]

    ast.should == target
  end
end
