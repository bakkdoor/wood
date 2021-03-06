module Wood::Nodes
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
        Wood::Types::Bool
      else
        @type || Wood::Types::CommonType[@left.type, @right.type]
      end
    end
  end

  class NumericOperator < Operator
    def boolean?
      false
    end
  end

  class Plus < NumericOperator
    def setup
      super
      @name = :+
    end
  end

  class Minus < NumericOperator
    def setup
      super
      @name = :-
    end
  end

  class Multiply < NumericOperator
    def setup
      super
      @name = :*
    end
  end

  class Divide < NumericOperator
    def setup
      super
      @name = :/
    end
  end
end
