module Forest::TreePattern
  # Matches anything it is matched / compared against.
  class AnyMatcher
    def === node
      return true
    end

    def == node
      return true
    end

    def sexp
      [:any_matcher]
    end

    def inspect
      sexp.inspect
    end
  end
end
