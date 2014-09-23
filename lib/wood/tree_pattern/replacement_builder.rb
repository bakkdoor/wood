module Wood::TreePattern
  class ReplacementBuilder
    def initialize(pattern_builder, &block)
      @pattern_builder = pattern_builder
      @block           = block
    end

    def replacement_for(node)
      @pattern_builder.vars.each do |v|
        singleton_class.__send__(:define_method, v.name) { v.value }
      end
      @node = node
      instance_eval(&@block)
    end

    def within(node, &block)
      node.__rewriter_class__.instance_eval &block
      node.rewrite!
    end

    private

    def node
      @node
    end
  end
end
