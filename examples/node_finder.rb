require_relative "../lib/wood"

require "pp"

include Wood
include Wood::Nodes

func_def = Function::Definition[
  name: :print_while_positive,
  type: Types::Int,
  args: [
    Function::Argument[name: :x, type: Types::Int]
  ],
  body: CodeBlock[
    WhileLoop[
      condition: Operator[
        name:  :<,
        left:  Variable::Reference[:x],
        right: IntLiteral[0]
      ],
      body: CodeBlock[
        Function::Call[
          name: :print,
          args: [
            Variable::Reference[:x]
          ]
        ],
        SubAssignment[
          var: Variable::Reference[:x],
          value: Operator[
            name:  :/,
            left:  Variable::Reference[:x],
            right: IntLiteral[2]
          ]
        ],
        IfElse[
          condition: Operator[
            name: :==,
            left: Operator[
              name:  :%,
              left:  Variable::Reference[:x],
              right: IntLiteral[2]
            ],
            right: IntLiteral[0]
          ],
          then_branch: Function::Call[
            name: :print,
            args: [
              StringLiteral["even!"]
            ]
          ]
        ]
      ]
    ]
  ]
]


# the above should look something like this in C:
# int print_while_positive(int x) {
#   while(x > 0) {
#     print(x);
#     x -= (x / 2);
#     if(x % 2 == 0)
#       print("even!");
#   }
# }

# let's find the inner print with the string literal:

pp func_def.find_child_node Function::Call[
  name: :print,
  args: [Node.with_type(Wood::Types::String)]
]
# => [:call, :print, [[:string_literal, "even!"]]]

if_else = func_def.find_child_node IfElse
pp if_else
# => [:if,
#      [:operator, :==,
#        [:operator, :%,
#          [:var_ref, :x],
#          [:int_literal, 2]],
#        [:int_literal, 0]],
#      [:call, :print, [[:string_literal, "even!"]]],
#      nil]

# we can also look up the tree:
pp func_def == if_else.find_parent_node(Function::Definition)
# => true

pp if_else == if_else.then_branch.find_parent_node(IfElse)
# => true

pp func_def.find_child_node(WhileLoop) == if_else.find_parent_node(WhileLoop)
# => true
