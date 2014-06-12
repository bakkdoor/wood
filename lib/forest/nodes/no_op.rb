module Forest::Nodes
  class NoOp < Node
    def type
      Forest::Types::Void
    end
  end
end
