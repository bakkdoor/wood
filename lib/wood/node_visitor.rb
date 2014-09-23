module Wood
  # Mixin module for {Wood::Node} visitors.
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

    def new_context
      Context.new(false)
    end

    def contexts
      @contexts ||= []
    end

    def context
      @contexts.last
    end

    def visit(node)
      contexts.push new_context
       __send__(node.node_name, node)
      contexts.pop
    end

    def visit_type(node)
      case node.type
      when Wood::Types::BuiltinType
        visit node.type
      when Wood::Types::CompoundType
        visit node.type
      when Wood::Types::CustomType
        visit node.type
      else
        visit node.type.type if node.type
      end
    end

    def array(nodes)
      nodes.each do |n|
        visit n
      end
    end
  end
end
