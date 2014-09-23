module Wood::TreePattern
  class PatternCallback < ReplacementBuilder
    alias_method :call, :replacement_for
  end
end
