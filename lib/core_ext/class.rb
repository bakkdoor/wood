class Class
  def delegate(options)
    methods = options[:methods]
    target  = options[:to]

    code = methods.map do |method|
      "
      def #{method}(*args, &block)
        #{target}.#{method}(*args, &block)
      end
      "
    end.join("\n")

    class_eval code
  end
end