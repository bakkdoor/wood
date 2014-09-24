module Wood
  module TreeRewriter
    class MultiPatternRewriter
      def initialize
        self.class.patterns self
      end

      def self.inherited(klass)
        klass.include Wood::TreePattern::Matcher
        klass.include Wood::TreeRewriter
      end
    end

    def self.new(&block)
      Class.new(MultiPatternRewriter, &block).new
    end

    module ClassMethods
      def patterns(*patterns)
        @patterns ||= []
        @patterns = patterns unless patterns.empty?
        @patterns
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    def rewrite(node, repeat = false)
      return do_rewrite(node, repeat) unless repeat

      changed = true
      while changed
        tmp     = do_rewrite(node, repeat)
        changed = tmp != node
        node    = tmp
      end

      return do_rewrite(node, false)
    end

    def do_rewrite(node, repeat = false)
      patterns.each do |p|
        node = p.replacement_for(node)
      end

      if node.respond_to? :each_child
        node.each_child do |c|
          node.set_child(c, rewrite(node.get_child(c), repeat))
        end
      else
        if Array === node
          node = node.map do |c|
            rewrite(c, repeat)
          end
        end
      end

      return node
    end

    def patterns
      self.class.patterns
    end
  end
end
