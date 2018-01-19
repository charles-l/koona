# TODO: split out semantic analysis pass
# TODO: add proper type check/inferance pass
module Koona
  OP_FUNCS = {
    "+" => "_op_do_add",
    "-" => "_op_do_sub",
    "*" => "_op_do_mul",
    "/" => "_op_do_div"
  }
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
      @tmp_counter = 0
    end

    def gentmp
      @tmp_counter += 1
      "_tmp#{@tmp_counter}"
    end

    def generate(ast)
      @output = ""
      @function_output = ""
      @scope_depth = 0
      @scope = {}
      @scope_stack = []
      @require_output = ""

      @output += "int main()\n{\n"
      @output += "kstack_frame_t *koona_stack = &koona_stack_root;\n"
      @output += generate_block ast
      @output += "return 0;\n}\n"
      @output = @function_output + @output
      # Put include stuff at the top
      @output = @require_output + @output
      @output = "#include \"#{File.dirname(__FILE__)}/base/runtime.c\"\n" + @output
      @output = "#include <stdbool.h>\n" + @output
    end

    def insert_symbol!(name, type)
      @scope[name] = {type: type, index: @scope.size}
      @scope[name]
    end

    def find_symbol(name)
      if !@scope[name].nil?
        @scope[name]
      else
        raise CompileError, "Failed to find symbol #{name}"
      end
    end

    def symbol_exists?(symbol)
      return @scope.key?(symbol)
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

    def transform_fcall_assign(stmt)
      r, t = generate_func_call(stmt.expr)
      stmt.expr = t
      r + generate_var_assignment(stmt)
    end

    def generate_stmt(stmt)
      case stmt
      when Koona::AST::NStatementList
        generate_stmt_list(stmt)
      when Koona::AST::NVariableDeclaration
        if symbol_exists?(stmt.id.name)
          v = find_symbol(stmt.id.name)
          message = "#{stmt.id.name} is already defined in scope as a #{v[:type]} at line #{v[:lineno]}"
          raise CompileError.new message, node: stmt
        end

        v = insert_symbol!(stmt.id.name, stmt.type.name)


        r = ""

        # now its defined, so reuse the assignment code
        if stmt.expr.class == AST::NFunctionCall # HACK: this was faster, but combine with assignment code in a transform pass
          r += transform_fcall_assign(stmt)
        else
          r += generate_var_assignment(stmt)
        end

        r + "koona_stack->n++; // track #{stmt.id.name}\n"
      when Koona::AST::NVariableAssignment
        if stmt.expr.class == AST::NFunctionCall
          transform_fcall_assign(stmt.expr)
        else
          generate_var_assignment(stmt)
        end
      when Koona::AST::NFunctionCall
        r, _ = generate_func_call(stmt)
        r
      when Koona::AST::NCFunctionCall
        generate_c_func_call(stmt)
      when Koona::AST::NRequire
        # TODO. Do this differently if you can think of an idea.
        @require_output += generate_require(stmt)
        ""
      when Koona::AST::NFunctionDeclaration
        # TODO. Do this differently if you can think of an idea.
        @function_output += generate_func_decl(stmt) # Send function declarations to @function_output
        "" # Return empty string so it doesn't define the function in main()
      when Koona::AST::NReturn
        generate_return(stmt)
      when Koona::AST::NIf
        generate_if(stmt)
      when String # arbitrary inline code
        stmt
      else
        raise CompileError, "need generate_stmt handler for #{stmt.class}"
      end
    end

    def id_or_generate(expr)
      if expr.class == Koona::AST::NIdentifier
        v = find_symbol(expr.name)
        "koona_stack->cells[/* #{expr.name} */ #{v[:index]}]"
      else
        generate_expr(expr)
      end
    end

    def generate_expr(expr)
      case expr
      when Koona::AST::NIdentifier
        s = find_symbol(expr.name)
        "unbox_#{s[:type]}(koona_stack->cells[/* #{expr.name} */ #{s[:index]}])"
      when Koona::AST::NBinaryOperator
        a = id_or_generate(expr.lhs)
        b = id_or_generate(expr.rhs)
        "#{OP_FUNCS[expr.op.value]}(#{a}, #{b})"
      when Koona::AST::NInteger
        "make_int(" + expr.value.to_s + ")"
      when Koona::AST::NDouble
        raise CompileError, "doubles aren't supported right now"
        expr.value.to_s
      when Koona::AST::NBool
        "make_bool(" + expr.value + ")"
      when Koona::AST::NString
        "make_string(" + expr.value + ")"
      when String
        expr
      else
        raise CompileError, "need generate_expr handler for #{expr.class.name}"
      end
    end

    def generate_require(stmt)
      if stmt.file.value.gsub("\"", "") =~ /.*\.[ch]/
        return "#include <" + stmt.file.value.gsub("\"", "") + ">\n"
      end
      raise CompileError.new("Error on: #{stmt.to_s}. Can only include C or C header files.", :node=>stmt)
    end

    def generate_if(stmt)
      r = ""
      raise CompileError.new("Expected expression!") if stmt.expr.nil?
      r += "if(#{generate_expr(stmt.expr)})"
      raise CompileError.new("if block is empty!") if stmt.block.nil?
      r += generate_block(stmt.block)
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

      v = find_symbol(stmt.id.name)
      r += "koona_stack->cells[/* #{stmt.id.name} */ #{v[:index]}]"
      if stmt.expr.nil?
        raise CompileError, "Need value for variable", node: stmt
      end
      r += " = "
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

      # insert the arguments
      stmt.arguments.variables.each do |var|
        insert_symbol! var.id.name, var.type.name
      end

      r += "kobj_t *#{stmt.id.name}(kstack_frame_t *koona_stack)\n"
      r += generate_block(stmt.block)
      pop_scope

      insert_symbol! stmt.id.name, "function"
      r
    end

    def generate_call_list(stmt, frame)
      stmt.variables.map do |e|
        "#{frame}.cells[#{frame}.n] = #{id_or_generate e}; #{frame}.n++;\n"
      end.join
    end

    def generate_func_call(stmt)
      r = ""
      if !symbol_exists?(stmt.id.name)
        message = "function '#{stmt.id.name}' has not been defined in scope!"
        raise CompileError.new(message)
      end
      ret = gentmp
      r += "// begin function call {\n"
      callee_frame = gentmp
      r = "kstack_frame_t #{callee_frame} = {0, {}, koona_stack, NULL};\n"
      r += "koona_stack->next = &#{callee_frame};\n"
      r += generate_call_list(stmt.arguments, callee_frame)
      r += "kobj_t *#{ret} = #{stmt.id.name}(&#{callee_frame});\n"
      r += "koona_stack->next = NULL;\n"
      r += "// } end function call\n"
      return r, ret
    end

    def generate_c_func_call(stmt)
      r = ""
      r += "#{stmt.id.name}("
      r += stmt.arguments.variables.map do |e|
        if e.class == Koona::AST::NIdentifier
          s = find_symbol(e.name)
          "unbox_#{s[:type]}(koona_stack->cells[#{s[:index]}])"
        else
          e
        end
      end.join(", ")
      r += ");\n"
      r
    end

    def generate_return(stmt)
      if @scope_depth == 0
        raise CompileError.new("return statement should be inside of a function declaration.")
      end
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
