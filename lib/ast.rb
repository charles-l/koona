module Koona
  module AST 
    class Node
      # Superclass to keep track of token info
      def initialize(token)
        @filename = token.filename
        @lineno = token.lineno
      end
      attr_reader :filename, :lineno, :offset
    end

    class NBlock
      def initialize(list)
        @statementlist = list
      end
      attr_accessor :statementlist

      # Debug
      def to_s
        "#{@statementlist}"
      end
    end

    class NStatementList
      def initialize
        @statements = []
      end

      def to_s
        "#{@statements}"
      end
      attr_accessor :statements
    end

    class NIdentifier < Node
      # Identfiers, like variable and function names
      def initialize(token)
        super token
        @name = token.value
      end
      attr_accessor :name

      # Debug
      def to_s
        "#{@name}"
      end
    end

    class NInteger < Node
      def initialize(token)
        super token
        @value = token.value
      end
      attr_accessor :value

      # Debug
      def to_s
        "#{@value}"
      end
    end

    class NDouble < Node
      def initialize(token)
        super token
        @value = token.value
      end
      attr_accessor :value

      # Debug
      def to_s
        "#{@value}"
      end
    end

    class NFunctionCall
      def initialize(id, arguments)
        @id = id
        @arguments = arguments
      end

      attr_accessor :id
      attr_accessor :arguments

      # Debug
      def to_s
        "#{@id}(#{@arguments})"
      end
    end

    class NFunctionDeclaration < Node
      def initialize(type, id, arguments, block, token)
        super token
        @type = type # return type
        @id = id
        @arguments = arguments
        @block = block
      end

      attr_accessor :type
      attr_accessor :id
      attr_accessor :arguments
      attr_accessor :block

      # Debug
      def to_s
        "#{@type} #{@id}(#{@arguments}){\n#{@block}\n}"
      end
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

      # Debug
      def to_s
        "#{@lhs} #{@op.value} #{@rhs}"
      end
    end

    class NVariableDeclaration < Node
      def initialize(type, id, expr, token)
        super token
        @type = type
        @id = id
        @expr = expr
      end
      attr_accessor :id
      attr_accessor :type
      attr_accessor :expr

      # Debug
      def to_s
        "#{@type} #{@id} = #{@expr}\n"
      end
    end

    class NReturn < Node
      def initialize(expr, token)
        super token
        @expr = expr
      end
      attr_accessor :expr
      def to_s
        "returns: #{expr}"
      end
    end

    class NVariableAssignment < Node
      def initialize(id, expr, token)
        super token
        @id = id
        @expr = expr
      end
      attr_accessor :id
      attr_accessor :expr

      # Debug
      def to_s
        "#{@id} = #{@expr}\n"
      end
    end

    class VariableList
      # For function declaration
      def initialize
        @variables = []
      end

      attr_accessor :variables

      def to_s
        "#{@variables.join(", ")}"
      end
    end

    class FunctionVar
      # For function argument declaration. Combine this with variable declartion eventually.
      def initialize(type, id)
        @type = type
        @id = id
      end

      attr_accessor :type
      attr_accessor :id
      def to_s
        "#{@type} #{@id}"
      end
    end
  end
end
