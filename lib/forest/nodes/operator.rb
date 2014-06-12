module Forest::Nodes
  class Operator < Node
    child_nodes :name, :left, :right

    BOOL_OPS     = [:<, :>, :<=, :>=, :==, :"!=", :"&&", :"||"]
    NON_BOOL_OPS = [:*, :/, :+, :-, :>>, :<<, :&, :|]

    def boolean?
      BOOL_OPS.include? name
    end

    def to_boolean
      if boolean?
        return self
      else
        return Operator[name: :"!=", left: self, right: IntLiteral[0]]
      end
    end

    def type
      if boolean?
        Forest::Types::Bool
      else
        @type || Forest::Types::CommonType[@left.type, @right.type]
      end
    end
  end
end
