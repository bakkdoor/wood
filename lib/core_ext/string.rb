class String
  # Returns a snake cases version of a {String}.
  #
  # @return [String] Snake cased version of `self`.
  # @example "FooBarBaz".snake_cased # => "foo_bar_baz"
  def snake_cased
    r1 = /([A-Z]+)([A-Z][a-z])/
    r2 = /([a-z\d])([A-Z])/

    gsub(r1,'\1_\2').gsub(r2,'\1_\2').tr("-", "_").downcase
  end

  # Returns a camel cased version of a {String}.
  #
  # @return [String] Camel cased version of `self`.
  # @example "foo_bar_baz".camel_cased # => "FooBarBaz"
  def camel_cased
    split("_").map(&:capitalize).join
  end

  # Returns `self` with all trailing whitespace removed.
  #
  # @return [String] `self` without any trailing whitespace.
  def without_trailing_whitespace
    lines.map(&:rstrip).join("\n")
  end

  def capitalized?
    c = self[0]
    c && c.upcase == c
  end
end
