module Forest::Nodes
  class Return < Node
    def self.[](options = nil)
      case options
      when Hash
        new(options)
      else
        new(expression: options)
      end
    end

    child_nodes :expression
    attr_accessor :function_def
  end
end
