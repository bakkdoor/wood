class Class
  def delegate(methods:, to:)
    code = methods.map do |method|
      "
      def #{method}(*args, &block)
        #{to}.#{method}(*args, &block)
      end
      "
    end.join("\n")

    class_eval code
  end
end