require_relative "../lib/wood"

require "pp"

include Wood
include Wood::Nodes

# Let's define some node types

class BinaryOperator < Node
  child_nodes :left, :right
end

class PlusOperator < BinaryOperator
end

class MinusOperator < BinaryOperator
end

class MultiplyOperator < BinaryOperator
end

class DivideOperator < BinaryOperator
end

class NumberLiteral < Wood::Node
  child_nodes :value
end

RedundantBinaryOpsRewriter = TreeRewriter.new do
  Zero = IntLiteral[0]

  pattern {
    opts = { left: l, right: Zero }
    PlusOperator[opts] | MinusOperator[opts]
  }.rewrite {
    l
  }

  pattern {
    op = { left: Zero, right: r }
    PlusOperator[op] | MinusOperator[op]
  }.rewrite {
    r
  }

  pattern {
    MultiplyOperator[left: Zero, right: _]
  }.rewrite {
    Zero
  }

  pattern {
    MultiplyOperator[left: _, right: Zero]
  }.rewrite {
    Zero
  }

  pattern {
    DivideOperator[left: _, right: Zero]
  }.perform {
    raise "Can't divide by zero. Fix this ASAP!"
  }

  pattern {
    PlusOperator[left: IntLiteral[x], right: IntLiteral[y]]
  }.rewrite {
    if x == y
      IntLiteral[x * 2]
    end
  }
end

# Now, let's use the rewriter:

add_zero = PlusOperator[
  left: MultiplyOperator[
    left:  IntLiteral[2],
    right: IntLiteral[0]
  ],
  right: IntLiteral[0]
]

# rewrite once:
result1 = RedundantBinaryOpsRewriter.rewrite add_zero

# rewrite repeatedly until no more rewrites happen:
result2 = RedundantBinaryOpsRewriter.rewrite add_zero, true

puts "Original AST:"
pp add_zero
# => [:plus_operator,
#      [:multiply_operator, [:int_literal, 2], [:int_literal, 0]],
#      [:int_literal, 0]]

puts "\nAfter a single rewrite:"
pp result1
# => [:multiply_operator, [:int_literal, 2], [:int_literal, 0]]

puts "\nAfter all possible rewrites:"
pp result2
# => [:int_literal, 0]

# Let's let it crash by dividing by (static) 0 literal

divide_by_zero = DivideOperator[
  left:  IntLiteral[10],
  right: MultiplyOperator[
    left:  IntLiteral[100],
    right: IntLiteral[0]
  ]
]

puts "\nDivide by zero with 1 rewrite:"
pp RedundantBinaryOpsRewriter.rewrite(divide_by_zero)
# => [:divide_operator, [:int_literal, 10], [:int_literal, 0]]

puts "\nDivide by zero with repeated rewrites fails:"
begin
  RedundantBinaryOpsRewriter.rewrite(divide_by_zero)
rescue => e
  pp e
end
# => #<RuntimeError: Can't divide by zero. Fix this ASAP!>

puts "\nRewrite 2 + 2 => 4"
pp RedundantBinaryOpsRewriter.rewrite(PlusOperator[
  left: IntLiteral[2],
  right: IntLiteral[2]
])
# => [:int_literal, 4]

puts "\nDon't rewrite 3 + 2"
pp RedundantBinaryOpsRewriter.rewrite(PlusOperator[
  left: IntLiteral[3],
  right: IntLiteral[2]
])
# => [:plus_operator, [:int_literal, 3], [:int_literal, 2]]
