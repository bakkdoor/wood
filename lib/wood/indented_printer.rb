module Wood
  # Mixin used for indented pretty-printing of code.
  # Expects `#io` and `#indentation` methods to work.
  module IndentedPrinter
    # Yields to a given block while indenting the output generated
    # within the block.
    def with_indentation
      indent
      newline
      yield
      unindent
      newline
    end

    # Prints any arguments passed to `io`.
    # @param args [Array] List of objects to print to `io`.
    def print(*args)
      args.each do |a|
        io << a
      end
    end

    # Prints a {String} to `io` followed by a line break.
    # @param str [String] String to be printed to `io` followed by a newline.
    def println(str)
      print str, "\n"
    end

    # Inserts a line break into `io` together with correct reindentation on
    # the next line.
    def newline
      io << "\n"
      io << (" " * @__indent__.to_i)
    end

    # Increases the current indentation by `indentation` spaces.
    def indent
      @__indent__ ||= 0
      @__indent__ += indentation
    end

    # Decreases the current indentation by `indentation` spaces.
    def unindent
      @__indent__ ||= 0
      @__indent__ -= indentation
    end
  end
end
