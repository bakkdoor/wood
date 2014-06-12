module Forest::TreePattern
  # Provides methods for searching for parent and child nodes
  # relative to a given {Node}.
  class NodeFinder
    # {Node} to start relative search from.
    attr_accessor :ast

    # Initializes {NodeFinder} with a given {Node}.
    #
    # @param ast [Node] AST node to start the search from.
    def initialize(ast = nil)
      @ast = ast
    end

    # Finds a parent node that matches a given pattern.
    #
    # @param node_pattern Node pattern to find a parent node with.
    # @return [Node] Parent node found via `node_pattern` or `nil`.
    def find_parent_node(node_pattern)
      ast = @ast
      while ast = ast.parent_node
        return ast if node_pattern === ast
      end
      return nil
    end

    # Finds any parent nodes that match a given pattern.
    #
    # @param node_pattern Node pattern to find parent nodes with.
    # @return [Array<Node>] All parent nodes that match `node_pattern`.
    def find_parent_nodes(node_pattern)
      ast = @ast
      found = []
      while ast = ast.parent_node
        found << ast if node_pattern === ast
      end
      return found
    end

    # Finds a child node that matches a given pattern.
    #
    # @param node_pattern Node pattern to find a child node with.
    # @return [Node] First child node that matches `node_pattern` or `nil`.
    def find_child_node(node_pattern)
      ast.child_nodes.each do |child|
        if found = __find_child_node__(child, node_pattern)
          return found
        end
      end
      return nil
    end

    # Finds all child nodes that match a given pattern.
    #
    # @param node_pattern Node pattern to find child nodes with.
    # @return [Array<Node>] All child nodes that match `node_pattern`.
    def find_child_nodes(node_pattern)
      found = []
      ast.child_nodes.each do |child|
        found += __find_child_nodes__(child, node_pattern)
      end
      found.uniq!
      return found
    end

    def delete_child_node(node_pattern)
      __delete_child_node__(ast, node_pattern)
    end

    def delete_child_nodes(node_pattern)
      __delete_child_nodes__(ast, node_pattern)
    end

    private

    def __find_child_node__(node, node_pattern)
      return node if node_pattern === node
      return nil unless node.respond_to?(:child_nodes)

      node.child_nodes.each do |child|
        if node_pattern === child
          return child
        end

        if found = __find_child_node__(child, node_pattern)
          return found
        end
      end

      return nil
    end

    def __find_child_nodes__(node, node_pattern)
      found = []
      found << node if node_pattern === node
      return found unless node.respond_to?(:child_nodes)

      node.child_nodes.each do |child|
        if node_pattern === child
          found << child
        end
        found += __find_child_nodes__(child, node_pattern)
      end

      return found
    end

    def __delete_child_node__(node, node_pattern)
      return node if node_pattern === node

      node.each_child_with_name do |child, child_name|
        case child
        when node_pattern
          node.set_child(child_name, nil)
          return child
        end

        if deleted = __delete_child_node__(child, node_pattern)
          return deleted
        end
      end
      return nil
    end


    def __delete_child_nodes__(node, node_pattern)
      deleted = []

      if Array === node
        to_del = node.select do |n|
          node_pattern === n
        end

        deleted += to_del

        node.each do |n|
          if del = __delete_child_nodes__(n, node_pattern)
            deleted += del
          end
        end

        to_del.each do |n|
          node.delete(n)
        end
      end

      if Forest::Node === node
        node.each_child_with_name do |child, child_name|
          case child
          when node_pattern
            node.set_child(child_name, nil)
            deleted << child
          end

          if del = __delete_child_nodes__(child, node_pattern)
            deleted += del
          end
        end
      end

      return deleted
    end
  end
end
