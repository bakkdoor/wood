module Forest::Nodes
  class ForLoop < Node
    child_nodes :init_op, :condition, :post_op, :body

    def setup
      @init_op   = init_op || NoOp[pos: pos]
      @post_op   = post_op || NoOp[pos: pos]
      @body      = body    || CodeBlock[pos: pos]
    end
  end
end
