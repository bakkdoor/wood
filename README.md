# Wood - Tree manipulation library

Wood is a library for creating, manipulating & rewriting trees,
in particular Abstract Syntax Trees (ASTs).

Wood was extracted from a source to source compiler project I worked on for
Marft Inc. in 2013/14.
Marft has granted me the rights to open source this library, so I'm releasing
it under the 3-Clause BSD license (see LICENSE file).

The compiler that was built using this library (which was then called Forest)
translated a subset of ANSI C to multiple target languages, including Java, C#
and JavaScript.

Wood provides an easy to use DSL for searching & rewriting whole sub-trees
in place, which can be used for things like subsequently translating a parse tree
into a target language tree (in the compiler project's case to Java::AST,
CSharp::AST and JavaScript::AST trees).

You can find some example tree node definition & rewriting rules in the examples
directory.
