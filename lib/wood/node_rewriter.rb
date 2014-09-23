module Wood
  class NodeRewriter
    instance_methods.each do |m|
      undef_method m unless m =~ /(^__|^send$|^object_id$)/
    end

    attr_reader :node

    def initialize(node, name = nil, parent = nil)
      @node = node
      @parent = parent
      @name = name
    end

    def method_missing(method, *args, &block)
      NodeRewriter.new(@node.__send__(method, *args, &block), method, self)
    end

    def rewrite(new_node_val)
      if new_node_val.respond_to? :node
        new_node_val = new_node_val.node
      end

      if @parent && @name
        @parent.set_child(@name, new_node_val)
      end
    end
  end
end
