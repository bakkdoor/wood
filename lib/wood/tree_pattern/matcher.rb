module Wood::TreePattern
  module Matcher
    module ClassMethods
      def pattern_builders
        @pattern_builders = [] unless @pattern_builders
        @pattern_builders
      end

      def pattern(&block)
        p = PatternBuilder.new(&block)
        pattern_builders << p
        p
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    def replacement_for(node)
      self.class.pattern_builders.each do |pb|
        if pb === node
          if replacement = pb.replacement_for(node)
            return replacement
          end
        end
      end
      return node
    end

    def === node
      self.class.pattern_builders.each do |p|
        if match = (p === node)
          return match
        end
      end
      return false
    end
  end
end
