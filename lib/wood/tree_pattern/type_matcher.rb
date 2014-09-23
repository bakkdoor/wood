module Wood::TreePattern
  class TypeMatcher
    def self.[](*options)
      case options.first
      when Hash
        options = options.first
        new(options[:node], options[:type])
      else
        new(*options)
      end
    end

    attr_reader :node_pattern, :type_pattern
    def initialize(node_pattern, type_pattern)
      @node_pattern = node_pattern || AnyMatcher.new
      @type_pattern = type_pattern
    end

    def === node
      val = @node_pattern === node
      if val && (@type_pattern === type(node))
        return val
      end
      return nil
    end

    def == node
      val = @node_pattern == node
      if val && (@type_pattern == type(node))
        return val
      end
      return nil
    end

    def sexp
      node_pat_sexp = if @node_pattern.respond_to?(:sexp)
        @node_pattern.sexp
      else
        @node_pattern.to_s
      end

      [:type_matcher, node_pat_sexp, @type_pattern.sexp]
    end

    def inspect
      sexp.inspect
    end

    private

    def type(node)
      if node.respond_to?(:type)
        node.type
      else
        node.instance_variable_get(:@type)
      end
    end
  end
end
