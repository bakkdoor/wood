module Forest::Nodes
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
      @type = Forest::Types::Int
      @base = base || 10
    end
  end

  class LongLiteral < Literal
    def setup
      @type = Forest::Types::Long
    end
  end

  class FloatLiteral < Literal
    def setup
      @type = Forest::Types::Float
    end
  end

  class DoubleLiteral < Literal
    def setup
      @type = Forest::Types::Double
    end
  end

  class StringLiteral < Literal
    def setup
      @type = Forest::Types::String
    end
  end

  class CharLiteral < Literal
    def setup
      @type = Forest::Types::Char
    end
  end

  class BoolLiteral < Literal
    def setup
      @type = Forest::Types::Bool
    end
  end

  class TrueLiteral < BoolLiteral
  end

  class FalseLiteral < BoolLiteral
  end
end
