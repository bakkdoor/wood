module Forest
  # Base node class.
  # Represents a generic AST node to be visited, processed & rewritten
  # in the compiler pipeline.
  class Node
    def self.with_type(type_pattern)
      Forest::TreePattern::TypeMatcher.new(self, type_pattern)
    end

    def with_type(type_pattern)
      Forest::TreePattern::TypeMatcher.new(self, type_pattern)
    end

    module ClassMethods
      # @return [Array<Symbol>]
      #         List of child node names for a {Node} class.
      def __child_nodes__
        superclass.__child_nodes__ + (@__child_nodes__ || [])
      end

      # @param child_nodes [Array<Symbol>]
      #        Sets the list of child nodes for a {Node} class.
      def child_nodes(*child_nodes)
        @__child_nodes__ = child_nodes
        attr_accessor *child_nodes
      end

      # Prefix to be ignored for #node_name
      attr_accessor :node_name_prefix

      # Overrides the default node name of a {Node} class.
      #
      # @param node_name [Symbol] New node name for {Node} class.
      def node_name(node_name = nil)
       @__node_name__ = node_name if node_name
        unless @__node_name__
          camel_cased = (name.split("::") - node_name_prefix.split("::")).join
          @__node_name__ = camel_cased.snake_cased.to_sym
        end
        @__node_name__
      end

      # Instantiates a new instance of `self` with `options`.
      def [](options = {})
        new(options)
      end
    end

    def self.__child_nodes__
      []
    end

    def self.inherited(klass)
      klass.extend ClassMethods
      klass.node_name_prefix = "Forest::Nodes"
      klass.__send__ :include, ::Forest::TreePattern::CombinatorialMatching
      klass.extend ::Forest::TreePattern::CombinatorialMatching
    end

    Position = Struct.new(:line, :column)

    # {Position} of node in the original source code.
    attr_reader   :pos
    # Type of node, like they're defined in {Forest::Types}.
    attr_accessor :type
    # Parent of this node within the AST.
    attr_accessor :parent_node

    def initialize(options = {})
      @pos  = options[:pos] || Position.new
      @type = options[:type]

      self.class.__child_nodes__.each do |c|
        node = options[c]
        instance_variable_set("@#{c}", node)
        if node.respond_to? :parent_node=
          node.parent_node = self
        end
      end

      setup
    end

    # Gets called on initialization, should be overwritten by subclass
    # if any checking needs to be done on the child node data etc.
    def setup
    end

    # @return [Symbol] Node name of this node.
    def node_name
      self.class.node_name
    end

    # @return [Array] S-expression version of `self`.
    def sexp
      [self.class.node_name, *child_nodes.map(&:sexp)]
    end

    # @param block [Proc, #call] Block to be called with each child node.
    def each_child(&block)
      self.class.__child_nodes__.each(&block)
    end

    def each_child_with_name(&block)
      self.class.__child_nodes__.each do |child_name|
        yield(get_child(child_name), child_name)
      end
    end

    # @return [Array<Node>] List of child nodes for `self`.
    def child_nodes
      child_node_names.map do |c|
        get_child(c)
      end
    end

    # @return [Array<Symbol>] List of child node names for `self`.
    def child_node_names
      self.class.__child_nodes__
    end

    # Compares a node to another.
    # @return [true, false] `true` if nodes equal, `false` otherwise.
    def == other
      case other
      when self.class
        each_child do |child|
          return false unless self.__send__(child) == other.__send__(child)
        end
        return true
      else
        return false
      end
    end

    # Matches a node with another.
    # @return [true, false] `true` if nodes match, `false` otherwise.
    def === other
      case other
      when self.class
        each_child do |child|
          child_val = get_child(child) || Forest::TreePattern::AnyMatcher.new
          return false unless child_val === other.get_child(child)
        end
        return true
      else
        return false
      end
    end

    def inspect
      sexp.inspect
    end

    # @param child_name [Symbol] Name of child to get node value for.
    # @return [Node] Child node named `child_name`.
    def get_child(child_name)
      __send__(child_name)
    end

    # @param child_name [Symbol] Name of child node to set value for.
    # @param node_val [Node] Node value to set child node to.
    def set_child(child_name, node_val)
      __send__("#{child_name}=", node_val)
    end

    # Allows per-node custom pattern matchers & rewriters.
    def __rewriter_class__
      @rewriter_class ||= Class.new do
        include Forest::TreePattern::Matcher
        include Forest::TreeRewriter
        patterns self.new
      end
    end

    def pattern(&block)
      __rewriter_class__.pattern(&block)
    end

    def rewrite!
      __rewriter_class__.new.rewrite(self)
    end

    delegate methods: [
      :find_parent_node, :find_parent_nodes,
      :find_child_node, :find_child_nodes,
      :delete_child_node, :delete_child_nodes
    ], to: :__node_finder__

    private

    def __node_finder__
      @node_finder ||= Forest::TreePattern::NodeFinder.new(self)
    end
  end
end

# sexp methods for core classes

[Symbol, String, Numeric, NilClass, TrueClass, FalseClass, Regexp].each do |c|
  c.class_eval do
    def sexp
      self
    end

    def each_child_with_name
      self
    end
  end
end

class Array
  def sexp
    map(&:sexp)
  end

  def node_name
    :array
  end

  def parent_node=(parent_node)
    each do |node|
      node.parent_node = parent_node if node.respond_to?(:parent_node=)
    end
  end

  def child_nodes
    self
  end

  alias_method :each_child_with_name, :each_with_index

  def set_child(child_name, node_val)
    case node_val
    when nil
      self.delete_at(child_name)
    else
      self[child_name] = node_val
    end
  end
end
