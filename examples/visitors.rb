require_relative "../lib/wood"

require "pp"

include Wood
include Wood::Nodes

class SourcePrinter
  include Wood::NodeVisitor
  include Wood::IndentedPrinter

  # We can keep custom context information available
  # for visited nodes up the visit call stack
  SourcePrinterContext = Struct.new(:ignored, :io_flushed)

  def new_context
    SourcePrinterContext.new(false, false)
  end

  attr_reader :io

  def initialize(io)
    @io = io
  end

  def indentation
    2
  end

  def var_ref(var_ref)
    print var_ref.name
  end

  def string_literal(sl)
    print sl.value.inspect
  end
end

class JavaPrinter < SourcePrinter
  def assign(assign)
    visit_type assign.var
    print " "
    visit assign.var
    print " = "
    visit assign.value
    print ";"
    newline
  end

  def string_type(st)
    print "String"
  end
end

class RubyPrinter < SourcePrinter
  def assign(assign)
    visit assign.var
    print " = "
    visit assign.value
    newline
  end
end

class JavaScriptPrinter < SourcePrinter
  def assign(assign)
    print "var "
    visit assign.var
    print " = "
    visit(assign.value)

    # # Context example:
    # # visit returns the context object for that visit
    # if visit(assign.value).io_flushed
    #   # do something here if context.io_flushed was set on visit of assign.value
    # end

    print ";"
    newline
  end

  def string_literal(sl)
    super
    # # Example use of context:
    # context.io_flushed = true
  end
end

assign_funcall = Assignment[
  var: Variable::Reference[name: :foo, type: Types::String],
  value: StringLiteral["Hello, World!"]
]

# Usage:

print "AST:           "
pp assign_funcall

print "Java output:   "
JavaPrinter.new($stdout).visit assign_funcall

print "Ruby output:   "
RubyPrinter.new($stdout).visit assign_funcall

print "JS output:     "
JavaScriptPrinter.new($stdout).visit assign_funcall
