module Wood::TreePattern
  module CombinatorialMatching
    # @return [OrMatcher] Matcher that matches `self` or `other`.
    def | other
      OrMatcher.new(self, other)
    end
  end

  # Matches a [Node], if any of two given patterns match it.
  class OrMatcher
    include CombinatorialMatching
    def initialize(a, b)
      @a = a
      @b = b
    end

    def === node
      @a === node || @b === node
    end

    def == node
      @a == node || @b == node
    end

    def sexp
      [:or_matcher, @a.sexp, @b.sexp]
    end

    def inspect
      sexp.inspect
    end
  end
end
