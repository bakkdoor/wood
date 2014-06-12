module Forest
  # Mixin module for {Forest::Node} visitors.
  module NodeVisitor
    module ClassMethods
      # @param node_names [Array<Symbol>] List of node names to be ignored.
      #
      # Creates an empty visit handler for all node names in `node_names`.
      def ignore_nodes(*node_names)
        node_names.each do |n|
          define_method(n) do |node|
            context.ignored = true
          end
        end
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    Context = Struct.new(:ignored)

    def contexts
      @contexts ||= []
    end

    def context
      @contexts.last
    end

    def visit(node)
      contexts.push Context.new(false)
       __send__(node.node_name, node)
      contexts.pop
    end

    def array(nodes)
      nodes.each do |n|
        visit n
      end
    end
  end
end
