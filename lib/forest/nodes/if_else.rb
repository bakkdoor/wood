module Forest::Nodes
  class IfElse < Node
    child_nodes :condition, :then_branch, :else_branch
    node_name   :if
  end
end
