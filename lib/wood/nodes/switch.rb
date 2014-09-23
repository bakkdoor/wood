module Wood::Nodes
  class Switch < Node
    class Case < Node
      child_nodes :expression, :body
    end

    class DefaultCase < Node
      child_nodes :body
    end

    child_nodes :expression, :cases
  end
end
