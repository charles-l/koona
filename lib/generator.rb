module Koona
  class CompileError < Exception
    def initialize(message, options={})
      message = "#{options[:node].filename}:#{options[:node].lineno} #{message}" if options[:node]
      super message
    end
    attr_reader :node
  end

  class Generator
    def initialize
      @self = nil
    end

    def generate(ast)
      @output = ""
      @function_output = ""
      @scope_depth = 0
      @scope = {}
      @scope_stack = []

      @output += "int main()\n{\n"
      @output += generate_block ast
      @output += "return 0;\n}\n"
      @output = @function_output + @output
    end

    def find_symbol(name)
      if !@scope[name].nil?
        @scope[name]
      end
    end

    def symbol_exists?(symbol)
      !find_symbol(symbol).nil?
    end

    def push_scope
      @scope_stack.push :self => @self, :scope => @scope
      @scope = {}
      @scope_depth = @scope_stack.size
      @self = "self#{@scope_depth}"
    end

    def pop_scope
      entry = @scope_stack.pop
      @self = entry[:self]
      @scope = entry[:scope]
      @scope_depth = @scope_stack.size
    end

    def generate_block(block)
      r = ""
      r += "{\n"
      block.statementlist.statements.each do |stmt|
        if stmt.class == Koona::AST::NBlock then
          r += generate_block stmt
        else
          r += generate_stmt stmt
        end
      end
      r += "}\n"
      r
    end

    def generate_stmt(stmt)
      case stmt
      when Koona::AST::NStatementList
        generate_stmt_list(stmt)
      when Koona::AST::NVariableDeclaration
        generate_var_decl(stmt)
      when Koona::AST::NVariableAssignment
        generate_var_assignment(stmt)
      when Koona::AST::NFunctionCall
        generate_func_call(stmt)
      when Koona::AST::NFunctionDeclaration
        @function_output += generate_func_decl(stmt) # Send function declarations to @function_output
        "" # Return empty string so it doesn't define the function in main()
      when Koona::AST::NReturn
        generate_return(stmt)
      else
        generate_expr stmt
        # FIXME Should raise an error, but for now, runs generate_expr instead
        # raise CompileError, "need generate_stmt handler for #{stmt.class.name}"
      end
    end

    def generate_expr(expr)
      case expr
      when Koona::AST::NIdentifier
        expr.name
      when Koona::AST::NBinaryOperator
        "#{generate_expr expr.lhs} #{expr.op.value} #{generate_expr expr.rhs}"
      when Koona::AST::NInteger
        expr.value.to_s
      when Koona::AST::NDouble
        expr.value.to_s
      else
        raise CompileError, "need generate_expr handler for #{expr.class.name}"
      end
    end

    def generate_var_decl(stmt)
      r = ""
      if symbol_exists?(stmt.id.name)
        v = find_symbol(stmt.id.name)
        message = "#{stmt.id.name} is already defined in scope as a #{v[:type]} at line #{v[:lineno]}"
        raise CompileError.new(message, :node=>stmt)
      end
      r += "#{stmt.type} #{stmt.id}"
      if !stmt.expr.nil?
        r += " = "
        r += generate_expr stmt.expr
      end
      r+= ";\n"

      @scope[stmt.id.name] = {
        :type => stmt.type.name,
        :lineno => stmt.lineno.to_i
      }

      r
    end

    def generate_stmt_list(stmt)
      r = ""
      stmt.statements.each do |s|
        r += generate_stmt(s)
      end
      r
    end

    def generate_var_assignment(stmt)
      r = ""
      if !symbol_exists?(stmt.id.name)
        message = "variable '#{stmt.id.name}' has not been defined in scope."
        raise CompileError.new(message, :node=>stmt)
      end
      if stmt.expr.nil?
        raise CompilerError.new("Missing assignment expression!", :node=>stmt)
      end
      r += "#{stmt.id} = "
      r += generate_expr stmt.expr
      r += ";\n"
      r
    end
    
    def generate_func_decl(stmt)
      r = ""
      if symbol_exists?(stmt.id.name)
        v = find_symbol(stmt.id.name)
        message = "function '#{stmt.id.name}' has already been defined in scope with a return type of #{v[:type]} at line #{v[:lineno]}"
        raise CompileError.new(message, :node=>stmt)
      end
      push_scope
      r += "#{stmt.type.name} #{stmt.id.name}("
      r += generate_var_list(stmt.arguments)
      r += ")\n"
      r += generate_block(stmt.block)
      pop_scope

      @scope[stmt.id.name] = {
        :kind => "function",
        :lineno => stmt.lineno
      }
      r
    end
    
    def generate_var_list(stmt)
      "#{stmt.variables.join(", ")}"
    end

    def generate_func_call(stmt)
      r = ""
      if !symbol_exists?(stmt.id.name)
        message = "function '#{stmt.id.name}' has not been defined in scope!"
        raise CompileError.new(message)
      end
      r += "#{stmt.id.name}("
      r += generate_var_list(stmt.arguments)
      r += ");\n"
      r
    end
    
    def generate_return(stmt)
      r = ""
      r += "return "
      if !stmt.expr.nil?
        r += generate_expr stmt.expr
      end
      r += ";\n"
      r
    end
  end
end
