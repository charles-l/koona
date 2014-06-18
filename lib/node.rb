class Node
end

class NExpression < Node
end

class NStatement < Node
end

class NIdentifier < NExpression
  attr_accessor :name
  def initialize(name)
    @name = name
  end

  def generate
    "#{@name}"
  end

  def to_s
    generate
  end
end

class NBlock < NExpression
  attr_accessor :statements
  attr_accessor :local_vars
  def initialize
    @statements = []
    @local_vars = []
  end
  def generate
     "#{@statements.join("")}"
  end
  def to_s
    generate
  end
end

class NInteger < NExpression
  attr_accessor :value
  def initialize(value)
    @value = value
  end
  def generate
     "#{@value}"
  end
  def to_s
    generate
  end
end

class NDouble < NExpression
  attr_accessor :value
  def initialize(value)
    @value = value
  end
end

class NMethodCall < NExpression
  attr_accessor :id
  attr_accessor :arguments
  def initialize(id, arguments)
    @id = id
    @arguments = arguments
  end
end

class NBinaryOperator < NExpression
  attr_accessor :op
  attr_accessor :lhs
  attr_accessor :rhs
  def initialize(lhs, op, rhs)
    @lhs = lhs
    @op = op
    @rhs = rhs
  end

  def generate
     "#{@lhs} #{@op} #{@rhs}"
  end

  def to_s
    generate
  end
end

class NVariableDeclaration < NExpression
  attr_accessor :id
  attr_accessor :type
  attr_accessor :expr
  def initialize(type, id, expr)
    @type = type
    @id = id
    @expr = expr
  end

  def generate
     "#{@type} #{@id} = #{@expr};\n"
  end

  def to_s
    generate
  end
end

class NVariableAssignment < NExpression
  attr_accessor :id
  attr_accessor :expr
  def initialize(id, expr)
    @id = id
    @expr = expr
  end

  def generate
    "#{@id} = #{@expr};\n"
  end

  def to_s
    generate
  end
end

class NReturn < NExpression
  attr_accessor :expr
  def initialize(expr)
    @expr = expr
  end
  def to_s
    ""
  end
end

class NFunctionCall < NExpression
  attr_accessor :id
  attr_accessor :arguments
  def initialize(id, arguments)
    @id = id
    @arguments = arguments
  end
 
  def generate
     "#{id}(#{arguments});\n"
  end
  def to_s
    generate
  end
end

class NExpressionStatement < NStatement
  attr_accessor :expression
  def initialize(expression)
    @expression = expression
  end
end

class NFunctionDeclaration < NStatement
  attr_accessor :type
  attr_accessor :id
  attr_accessor :arguments
  attr_accessor :block
  def initialize(type, id, arguments, block)
    @type = type
    @id = id
    @arguments = arguments
    @block = block
  end

  def generate
    "#{@type} #{@id} (#{@arguments})\n{\n#{@block}}\n"
  end
  def to_s
    ""
  end
end

class NAssignment < NStatement
  attr_accessor :id
  attr_accessor :assignmentExpr
  def initialize(id, assignmentExpr)
    @id = id
    @assignmentExpr = assignmentExpr
  end
end

class VariableList
  attr_accessor :variables
  def initialize
    @variables = []
  end

  def generate
     "#{@variables.join(",")}"
  end
  def to_s
    generate
  end
end

class FunctionVar < NExpression
  attr_accessor :type
  attr_accessor :id

  def initialize(type, id)
    @type = type
    @id = id
  end

  def generate
     "#{@type} #{@id}"
  end

  def to_s
    generate
  end
end
