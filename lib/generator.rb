module Koona
  class CompileError < Exception
    def initialize(message, options={})
      message = "#{options[:node].filename}:#{options[:node].lineno}: #{message}" if options[:node]
      super message
    end
    attr_reader :node
  end

  class Generator
    def initialize
      @self = nil
    end

    def generate(ast)
      @indent = 0
      @output = ""
      @scope_depth = 0
      @scope = {}
      @scope_stack = []

      generate_block ast
    end

    def with_indent &block
      @indent += 1
      yield
      @indent -= 1
    end

    def write(s)
      @output += ("  " * @indent)
      @output += s
    end

    def writeln(s="")
      write(s)
      @output += "\n"
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
      writeln "{"
      with_indent do
        block.statements.each do |stmt|
          if stmt.class != Koona::AST::NBlock then
            generate_stmt stmt
          else
            generate_block stmt
          end
        end
      end
      writeln "}"
      @output
    end

    def generate_stmt(stmt)
      case stmt
      when Koona::AST::NFunctionCall
        generate_func_call(stmt)
      when Koona::AST::NVariableDeclaration
        generate_var_decl(stmt)
      when Koona::AST::NVariableAssignment
        generate_var_assignment(stmt)
      when Koona::AST::NReturn
        generate_return(stmt)
      when Koona::AST::NFunctionDeclaration
        generate_func_decl(stmt)
      else
        raise CompileError, "need generate_stmt handler for #{stmt.class.name}"
      end
    end

    def generate_expr(expr)
      case expr
      when Koona::AST::NIdentifier
        write expr.name
      when Koona::AST::NBinaryOperator
        generate_expr(expr.lhs)
        write "#{expr.op.value}"
        generate_expr(expr.rhs)
      when Koona::AST::NInteger
        write expr.value.to_s
      when Koona::AST::NDouble
        write expr.value
      else
        raise CompileError, "need generate_expr handler for #{expr.class.name}"
      end
    end

    def generate_var_decl(stmt)
      if symbol_exists?(stmt.id.name)
        v = find_symbol(stmt.id.name)
        message = "#{stmt.id.name} is already defined in scope as a #{v[:type]} at line #{v[:lineno]}"
        raise CompileError.new(message, :node=>stmt)
      end
      write "#{stmt.type} #{stmt.id}"
      if !stmt.expr.nil?
        write " = "
        generate_expr stmt.expr
      end
      writeln ";"

      @scope[stmt.id.name] = {
        :type => stmt.type.name,
        :lineno => stmt.lineno.to_i
      }
    end

    def generate_var_assignment(stmt)
      if !symbol_exists?(stmt.id.name)
        message = "variable '#{stmt.id}' has not been defined in scope."
        raise CompileError.new(message, :node=>stmt)
      end
      if stmt.expr.nil?
        raise CompilerError.new("Missing assignment expression!", :node=>stmt)
      end
      write "#{stmt.id} = "
      generate_expr stmt.expr
      writeln ";"
    end
    
    def generate_func_decl(stmt)
      if symbol_exists?(stmt.id.name)
        v = find_symbol(stmt.id.name)
        message = "function '#{stmt.id}' has already been defined in scope with a return type of #{v[:type]} at line #{v[:lineno]}"
        raise CompileError.new(message, :node=>stmt)
      end
      push_scope
      write "#{stmt.type.name} #{stmt.id.name}("
      generate_var_list(stmt.arguments)
      write ")\n{\n"
      with_indent do
        generate_block(stmt.block)
      end
      writeln "}"
      pop_scope

      @scope[stmt.id.name] = {
        :kind => "function",
        :lineno => stmt.lineno
      }
    end
    
    def generate_var_list(stmt)
      write "#{stmt.variables.join(", ")}"
    end

    def generate_func_call(stmt)
    end
    
    def generate_return(stmt)
      write "return"
      if !stmt.expr.nil?
        generate_expr stmt.expr
      end
      writeln ";"
    end
  end
end
