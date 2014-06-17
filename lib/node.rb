class NExpression
end

class NStatement
end

class NIdentifier < NExpression
  attr_accessor :name
  def initialize(name)
    self.name = name
  end
  
  def generate
     "#{self.name}"
  end

  def to_s
    generate
  end
end

class NBlock < NExpression
  attr_accessor :statements
  attr_accessor :local_vars
  def initialize
    self.statements = []
    self.local_vars = []
  end
  def generate
     "#{statements}"
  end
  def to_s
    generate
  end
end

class NInteger < NExpression
  attr_accessor :value
  def initialize(value)
    self.value = value
  end
  def generate
     "#{self.value}"
  end
  def to_s
    generate
  end
end

class NDouble < NExpression
  attr_accessor :value
  def initialize(value)
    self.value = value
  end
end

class NMethodCall < NExpression
  attr_accessor :id
  attr_accessor :arguments
  def initialize(id, arguments)
    self.id = id
    self.arguments = arguments
  end
end

class NBinaryOperator < NExpression
  attr_accessor :op
  attr_accessor :lhs
  attr_accessor :rhs
  def initialize(lhs, op, rhs)
    self.lhs = lhs
    self.op = op
    self.rhs = rhs
  end

  def generate
     "#{self.lhs} #{self.op} #{self.rhs}"
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
    self.type = type
    self.id = id
    self.expr = expr
  end
  
  def generate
     "#{self.type} #{self.id} = #{self.expr};\n"
  end

  def to_s
    generate
  end
end

class NVariableAssignment < NExpression
  attr_accessor :id
  attr_accessor :expr
  def initialize(id, expr)
    self.id = id
    self.expr = expr
  end
  
  def generate
     "#{self.id} = #{self.expr};\n"
  end

  def to_s
    generate
  end
end

class NReturn < NExpression
  attr_accessor :expr
  def initialize(expr)
    self.expr = expr
  end
end

class NFunctionCall < NExpression
  attr_accessor :id
  attr_accessor :arguments
  def initialize(id, arguments)
    self.id = id
    self.arguments = arguments
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
    self.expression = expression
  end
end

class NFunctionDeclaration < NStatement
  attr_accessor :type
  attr_accessor :id
  attr_accessor :arguments
  attr_accessor :block
  def initialize(type, id, arguments, block)
    self.type = type
    self.id = id
    self.arguments = arguments
    self.block = block
  end

  def generate
    "#{self.type} #{self.id} (#{self.arguments})\n{\n#{self.block}}\n"
  end
  def to_s
    return ""
  end
end

class NAssignment < NStatement
  attr_accessor :id
  attr_accessor :assignmentExpr
  def initialize(id, assignmentExpr)
    self.id = id
    self.assignmentExpr = assignmentExpr
  end
end

class VariableList
  attr_accessor :variables
  def initialize
    self.variables = []
  end

  def generate
     "#{self.variables.join(",")}"
  end
  def to_s
    generate
  end
end

class FunctionVar < NExpression
  attr_accessor :type
  attr_accessor :id

  def initialize(type, id)
    self.type = type
    self.id = id
  end

  def generate
     "#{self.type} #{self.id}"
  end

  def to_s
    generate
  end
end
