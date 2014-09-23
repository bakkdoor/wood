module Wood::TreePattern
  PatternVariable = Struct.new(:name, :value)

  class VariableMatcher
    def initialize(pattern_builder, var_name)
      @pattern_builder = pattern_builder
      @var_name        = var_name
    end

    def === node
      @pattern_builder.add_var(PatternVariable.new(@var_name, node))
      return true
    end

    def == node
      return true
    end

    def sexp
      [:variable_matcher, @var_name]
    end

    def inspect
      sexp.inspect
    end

    def with_type(type_pattern)
      Wood::TreePattern::TypeMatcher.new(self, type_pattern)
    end
  end
end
