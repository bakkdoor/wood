module Forest::Nodes
  module Function
    class Argument < Node
      child_nodes :storage, :type, :name

      def sexp
        [type.sexp, name]
      end
    end

    class Declaration < Node
      child_nodes :storage, :type, :name, :args

      attr_accessor :scope
    end

    class Definition < Node
      child_nodes :storage, :type, :name, :args, :body

      attr_accessor :scope

      def setup
        @args = args || []
        @body = body || CodeBlock[pos: pos]
      end
    end

    class Call < Node
      child_nodes :name, :args
      node_name   :call

      attr_accessor :function

      def setup
        @args = args || []
      end

      def type
        if @function
          @function.type
        end
      end
    end
  end
end
