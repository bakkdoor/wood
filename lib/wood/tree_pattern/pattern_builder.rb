module Wood::TreePattern
  # Helper class for building node patterns & replacement actions.
  class PatternBuilder < BasicObject
    attr_reader :pattern, :vars, :replacement_builder

    def initialize(&block)
      @vars      = []
      @pattern   = instance_eval(&block) if block
      @callbacks = []
    end

    def _(var_name = nil)
      if var_name
        VariableMatcher.new(self, var_name)
      else
        AnyMatcher.new
      end
    end

    def add_var(var)
      @vars << var
    end

    def rewrite(&block)
      @replacement_builder = ReplacementBuilder.new(self, &block)
    end

    def perform(&block)
      @callbacks << PatternCallback.new(self, &block)
    end

    def method_missing(var_name, var_value = nil)
      if var_value
        add_var PatternVariable.new(var_name, var_value)
        return var_value
      else
        return VariableMatcher.new(self, var_name)
      end
    end

    def replacement_for(node)
      if rb = replacement_builder
        return rb.replacement_for(node)
      end
    end

    def === node
      if val = (pattern === node)
        @callbacks.each do |c|
          c.call(node)
        end
        return val
      end
      return false
    end
  end
end
