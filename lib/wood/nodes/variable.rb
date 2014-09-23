module Wood::Nodes
  module Variable
    class Declaration < Node
      child_nodes :type, :name, :init_val
      node_name   :var_decl
    end

    class Reference < Node
      def self.[](options)
        case options
        when Hash
          new(options)
        else
          new(name: options)
        end
      end

      child_nodes :name
      node_name   :var_ref

      attr_accessor :var
    end
  end
end
