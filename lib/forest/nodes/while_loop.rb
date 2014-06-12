module Forest::Nodes
  class WhileLoop < Node
    child_nodes :condition, :body
    node_name   :while

    def setup
      @body = body || CodeBlock[pos: pos]
    end
  end
end
