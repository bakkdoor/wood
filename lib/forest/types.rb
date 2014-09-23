module Forest
  module Types
    module TypeMatching
      def self.included(klass)
        klass.__send__ :include, Forest::TreePattern::CombinatorialMatching
        klass.extend Forest::TreePattern::CombinatorialMatching
      end
    end

    class CompoundType
      include TypeMatching
      def self.[](type)
        new(type)
      end

      attr_accessor :type
      def initialize(type)
        @type = type
      end

      def == other
        case other
        when self.class
          return type == other.type
        else
          return false
        end
      end

      def numeric?
        false
      end

      def builtin?
        type && type.builtin?
      end

      def zero_value
        @zero_value ||= Forest::Nodes::Null.new
      end
    end


    class Array < CompoundType
      def self.[](*options)
        case options.first
        when Hash
          options = options.first
          new(options[:type], options[:size])
        else
          new(*options)
        end
      end

      attr_reader :size
      def initialize(type, size = nil)
        super(type)
        @size = size
      end

      def name
        [:array, type.name]
      end

      def node_name
        :array_type
      end

      def == other
        case other
        when Array
          if size && other.size
            return type == other.type && size == other.size
          else
            return type == other.type
          end
        else
          return false
        end
      end

      def === other
        case other
        when Array
          if size && other.size
            return type === other.type && size === other.size
          else
            return type === other.type
          end
        else
          return false
        end
      end

      def numeric?
        type && type.numeric?
      end

      def builtin?
        type && type.builtin?
      end

      def sexp
        [:array, type.sexp, size.sexp]
      end
    end

    class CustomType < Struct.new(:type)
      include TypeMatching
      def self.[](type)
        case type
        when BuiltinType
          return type
        when CustomType
          return type
        when CompoundType
          return type
        else
          new(type)
        end
      end

      def node_name
        :custom_type
      end

      def sexp
        [:custom_type, type.sexp]
      end

      def == other
        case other
        when CustomType
          return type == other.type
        else
          return type == other
        end
      end

      def === other
        case other
        when CustomType
          return type === other.type
        else
          return type === other
        end
      end

      def numeric?
        false
      end

      def builtin?
        false
      end

      def name
        type.name
      end

      def method_missing(method, *args)
        type.__send__(method, *args)
      end
    end

    class BuiltinType < Struct.new(:name)
      include TypeMatching
      attr_reader   :aliases
      attr_accessor :zero_value
      def initialize(name, numeric = false, *aliases)
        super(name)

        @aliases = aliases
        @numeric = numeric

        if numeric?
          Types::NUMERIC_TYPES << self
        else
          Types::NON_NUMERIC_TYPES << self
        end
      end

      def numeric?
        @numeric
      end

      def builtin?
        true
      end

      def sexp
        name
      end

      def node_name
        (Array(name).map(&:to_s).join("_") + "_type").snake_cased.to_sym
      end

      def == other
        case other
        when BuiltinType
          return name == other.name
        else
          return false
        end
      end

      def type
        self
      end

      def zero_value
        @zero_value ||= Forest::Nodes::Null.new
      end
    end

    class NumericType < BuiltinType
      def initialize(name, *aliases)
        super(name, true, *aliases)
      end

      def zero_value
        @zero_value ||= Forest::Nodes::Literal[type: self, value: 0]
      end
    end

    class BooleanType < BuiltinType
      def initialize(name, *aliases)
        super(name, false, *aliases)
      end

      def zero_value
        @zero_value ||= Forest::Nodes::FalseLiteral.new
      end
    end

    module CommonType
      def self.[](*types)
        common_type_for(*types)
      end

      def self.type_order
        @@order ||= [
          Any,
          Bool,
          U8,
          I8,
          U16,
          Short,
          U32,
          I32,
          Int,
          U64,
          I64
        ]
      end

      def self.common_type_for(*types)
        type_order[types_to_indices(types).last]

      end

      def self.smallest_type_of(*types)
        type_order[types_to_indices(types).first]
      end

      private

      def self.types_to_indices(types)
        idx = Set.new(types).map do |t|
          type_order.index(t).to_i
        end.sort
      end
    end

    class AnyType < BuiltinType
      def initialize(name, *aliases)
        super(name, false, *aliases)
      end

      def == other
        true
      end

      def === other
        true
      end
    end


    NUMERIC_TYPES     = Set.new
    NON_NUMERIC_TYPES = Set.new

    Any               = AnyType.new :Any, :any, :Object, :object
    Int               = NumericType.new :int
    Float             = NumericType.new :float
    Short             = NumericType.new :short
    Long              = NumericType.new :long
    Double            = NumericType.new :double
    Char              = BuiltinType.new :char
    String            = BuiltinType.new :string
    Void              = BuiltinType.new :void
    Null              = BuiltinType.new :null
    Bool              = BooleanType.new :bool

    U8                = NumericType.new :u8,  :uint8_t
    U16               = NumericType.new :u16, :uint16_t
    U32               = NumericType.new :u32, :uint32_t
    U64               = NumericType.new :u64, :uint64_t

    I8                = NumericType.new :i8,  :int8_t
    I16               = NumericType.new :i16, :int16_t
    I32               = NumericType.new :i32, :int32_t
    I64               = NumericType.new :i64, :int64_t
  end
end
