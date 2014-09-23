Gem::Specification.new do |s|
  s.name = "wood"
  s.version = "0.1.0"

  s.authors = ["Christopher Bertels"]
  s.date = "2014-09-23"
  s.email = "chris@fancy-lang.org"

  files = ["README.md", "LICENSE", "Rakefile", "Gemfile"] +
    Dir.glob("lib/**/*.rb") +
    Dir.glob("spec/**/*.rb") +
    Dir.glob("examples/**/*.rb")

  s.files = files
  s.require_path = "lib"

  s.license = "BSD"

  s.has_rdoc = false
  s.homepage = "https://github.com/bakkdoor/wood"
  s.summary = "Wood - Tree manipulation library"

  s.required_ruby_version = '>= 2.0.0'

  s.description = <<EOS
Wood is a library for creating, manipulating & rewriting trees,
in particular Abstract Syntax Trees (ASTs).

It provides an easy to use DSL for searching & rewriting whole sub-trees
in place, which can be used for things like translating a parse tree into a
target language tree, doing type analysis, writing compiler optimization passes
and more.
EOS
end
