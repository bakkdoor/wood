module Forest::Nodes
  class CodeBlock < Node
    def self.[](*options)
      case opts = options.first
      when Hash
        new(opts)
      else
        new(expressions: options)
      end
    end

    include Enumerable

    child_nodes :expressions

    def setup
      @expressions = Array(expressions).flatten
    end

    def sexp
      expressions.map(&:sexp)
    end

    def empty?
      expressions.empty?
    end

    def size
      expressions.size
    end

    def each(&block)
      @expressions.each(&block)
    end

    def << node
      @expressions << node
    end

    def [](idx)
      @expressions[idx]
    end
  end
end
