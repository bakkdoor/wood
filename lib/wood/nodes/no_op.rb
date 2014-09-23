module Wood::Nodes
  class NoOp < Node
    def type
      Wood::Types::Void
    end
  end
end
