require_relative "../lib/wood"

require "pp"

include Wood
include Wood::Nodes

# Let's define some node types

class BinaryOperator < Node
  child_nodes :left, :right
end

class PlusOp < BinaryOperator
end

class MinusOp < BinaryOperator
end

class MultiplyOp < BinaryOperator
end

class DivideOp < BinaryOperator
end

RedundantBinaryOpsRewriter = TreeRewriter.new do
  ZERO = IntLiteral[0]

  pattern {
    opts = { left: l, right: ZERO }
    PlusOp[opts] | MinusOp[opts]
  }.rewrite {
    l
  }

  pattern {
    op = { left: ZERO, right: r }
    PlusOp[op] | MinusOp[op]
  }.rewrite {
    r
  }

  pattern {
    MultiplyOp[left: ZERO, right: _] | MultiplyOp[left: _, right: ZERO]
  }.rewrite {
    ZERO
  }

  pattern {
    DivideOp[left: _, right: ZERO]
  }.perform {
    raise "Can't divide by zero. Fix this ASAP!"
  }

  pattern {
    PlusOp[left: IntLiteral[x], right: IntLiteral[y]]
  }.rewrite {
    if x == y
      IntLiteral[x * 2]
    end
  }
end

# Now, let's use the rewriter:

add_zero = PlusOp[
  left: MultiplyOp[
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
# => [:plus_op,
#      [:multiply_op, [:int_literal, 2], [:int_literal, 0]],
#      [:int_literal, 0]]

puts "\nAfter a single rewrite:"
pp result1
# => [:multiply_op, [:int_literal, 2], [:int_literal, 0]]

puts "\nAfter all possible rewrites:"
pp result2
# => [:int_literal, 0]

# Let's let it crash by dividing by (static) 0 literal

divide_by_zero = DivideOp[
  left:  IntLiteral[10],
  right: MultiplyOp[
    left:  IntLiteral[100],
    right: IntLiteral[0]
  ]
]

puts "\nDivide by zero with 1 rewrite:"
pp RedundantBinaryOpsRewriter.rewrite(divide_by_zero)
# => [:divide_op, [:int_literal, 10], [:int_literal, 0]]

puts "\nDivide by zero with repeated rewrites fails:"
begin
  RedundantBinaryOpsRewriter.rewrite(divide_by_zero)
rescue => e
  pp e
end
# => #<RuntimeError: Can't divide by zero. Fix this ASAP!>

puts "\nRewrite 2 + 2 => 4"
pp RedundantBinaryOpsRewriter.rewrite(PlusOp[
  left: IntLiteral[2],
  right: IntLiteral[2]
])
# => [:int_literal, 4]

puts "\nDon't rewrite 3 + 2"
pp RedundantBinaryOpsRewriter.rewrite(PlusOp[
  left: IntLiteral[3],
  right: IntLiteral[2]
])
# => [:plus_op, [:int_literal, 3], [:int_literal, 2]]
