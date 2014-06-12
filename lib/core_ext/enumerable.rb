module Enumerable
  # Helper class for iterating over elements in a {Enumerable} while
  # calling a given block between each element.
  class InBetweenEnum
    include Enumerable
    def initialize(enum, block)
      @enum = enum
      @block = block
    end

    # Calls a given block with each element while also calling `@block`
    # in between each element during iteration.
    def each
      block = -> { block = @block }
      @enum.each do |x|
        block.call
        yield x
      end
    end
  end

  # Creates a {InBetweenEnum} for iteration while calling `block` in between.
  #
  # @param block [Proc, #call] Block to be called in between each element
  #
  # @return [InBetweenEnum] Enumerable like object for iterating over elements
  #                         in `self` while calling `block` in between.
  def in_between(&block)
    InBetweenEnum.new(self, block)
  end

  # Same as #map but passing along the index with each element to a given block.
  #
  # @return [Array] Mapped items based on block given.
  # @example
  #         ["a","b","c"].map_with_index do |x, i|
  #           x + (i * 2).to_s
  #         end
  #         => ["a0", "b2", "c4"]
  def map_with_index
    arr = []
    each_with_index do |x, i|
      arr << yield(x, i)
    end
    arr
  end
end
