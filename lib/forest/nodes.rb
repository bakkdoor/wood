module Forest
  module Nodes
    Node = Forest::Node
  end
end

require_relative "nodes/no_op"
require_relative "nodes/nested_node"
require_relative "nodes/literals"
require_relative "nodes/assignment"
require_relative "nodes/operator"
require_relative "nodes/null"
require_relative "nodes/code_block"
require_relative "nodes/function"
require_relative "nodes/if_else"
require_relative "nodes/return"
require_relative "nodes/break"
require_relative "nodes/continue"
require_relative "nodes/for_loop"
require_relative "nodes/while_loop"
require_relative "nodes/switch"
require_relative "nodes/variable"
