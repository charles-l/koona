module Koona
  module AST
    class Node
      def initialize(token)
        @filename = token.filename
        @lineno = token.lineno
        @token = token
      end
      attr_reader :filename, :lineno, :offset, :token
    end

    class NBlock
      def initialize
        @statements = []
        return Koona::Token.new(nil, nil, nil)
      end
      attr_accessor :statements
    end

    class NIdentifier < Node
      def initialize(token)
        super token
        @name = token.value
      end
      attr_accessor :name
    end

    class NInteger < Node
      def initialize(token)
        super token
        @value = token.value
      end
      attr_accessor :value
    end

    class NDouble < Node
      def initialize(token)
        super token
        @value = token.value
      end
      attr_accessor :value
    end

    class NFunctionCall
      def initialize(id, arguments)
        @id = id
        @arguments = arguments
      end

      attr_accessor :id
      attr_accessor :arguments
    end

    class NFunctionDeclaration < Node
      def initialize(type, id, arguments, block, token)
        super token
        @type = type
        @id = id
        @arguments = arguments
        @block = block
      end

      attr_accessor :type
      attr_accessor :id
      attr_accessor :arguments
      attr_accessor :block
    end

    class NBinaryOperator < Node
      def initialize(lhs, op, rhs)
        super lhs
        @lhs = lhs
        @op = op
        @rhs = rhs
      end
      attr_accessor :op
      attr_accessor :lhs
      attr_accessor :rhs
    end

    class NVariableDeclaration < Node
      def initialize(type, id, expr, token)
        super token
        @type = type
        @id = id
        @expr = expr
        token
      end
      attr_accessor :id
      attr_accessor :type
      attr_accessor :expr
    end

    class NVariableAssignment < Node
      def initialize(id, expr, token)
        super token
        @id = id
        @expr = expr
      end
      attr_accessor :id
      attr_accessor :expr
    end

    class NReturn < Node
      def initialize(expr, token)
        super token
        @expr = expr
      end
      attr_accessor :expr
    end

    class VariableList
      def initialize
        @variables = []
      end

      attr_accessor :variables
    end

    class FunctionVar
      def initialize(type, id)
        @type = type
        @id = id
      end

      attr_accessor :type
      attr_accessor :id
    end
  end
end
