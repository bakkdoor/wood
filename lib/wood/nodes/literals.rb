module Wood::Nodes
  class Literal < Node
    def self.[](options = nil)
      case options
      when Hash
        new(options)
      else
        new(value: options)
      end
    end

    child_nodes :type, :value

    def sexp
      [node_name, value]
    end
  end

  class IntLiteral < Literal
    child_nodes :base
    def setup
      @type = Wood::Types::Int
      @base = base || 10
    end
  end

  class LongLiteral < Literal
    def setup
      @type = Wood::Types::Long
    end
  end

  class FloatLiteral < Literal
    def setup
      @type = Wood::Types::Float
    end
  end

  class DoubleLiteral < Literal
    def setup
      @type = Wood::Types::Double
    end
  end

  class StringLiteral < Literal
    def setup
      @type = Wood::Types::String
    end
  end

  class CharLiteral < Literal
    def setup
      @type = Wood::Types::Char
    end
  end

  class BoolLiteral < Literal
    def setup
      @type = Wood::Types::Bool
    end
  end

  class TrueLiteral < BoolLiteral
  end

  class FalseLiteral < BoolLiteral
  end
end
