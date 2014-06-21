class Koona::Parser
  token TIDENTIFIER TDOUBLE TINTEGER
  token TCEQ TCNE TCLT TCLE TCGT TCGE TEQUAL
  token TLPAREN TRPAREN TLBRACE TRBRACE TCOMMA TDOT
  token TPLUS TMINUS TMUL TDIV
  token TRETURN

  start program
  rule
  program : stmts {result = Koona::AST::NBlock.new; result.statements << val[0]}
stmts : stmt {result = Koona::AST::NBlock.new; result.statements << val[0]}
| stmts stmt {val[0].statements << val[1]}

stmt : return_stmt
| expr
| block 
| func_decl
| var_decl

block : TLBRACE TRBRACE {result = Koona::AST::NBlock.new}
        | TLBRACE stmts TRBRACE {result = Koona::AST::NBlock.new; result.statements << val[1]}

  var_decl : ident ident TEQUAL expr {result = Koona::AST::NVariableDeclaration.new(val[0], val[1], val[3], val[0])}

  func_decl : ident ident TLPAREN func_decl_args TRPAREN block 
            {result = Koona::AST::NFunctionDeclaration.new(val[0], val[1], val[3], val[5], val[0])}

  func_decl_args : {result = Koona::AST::VariableList.new}
                 | ident ident {result = Koona::AST::VariableList.new; result.variables << Koona::AST::FunctionVar.new(val[0], val[1])}
                 | func_decl_args TCOMMA ident ident {val[0].variables << Koona::AST::FunctionVar.new(val[2], val[3])}
  return_stmt : TRETURN {result = Koona::AST::NReturn.new(val[0], nil)}
              | TRETURN expr {result = Koona::AST::NReturn.new(val[0], val[1])}

  ident : TIDENTIFIER {result = Koona::AST::NIdentifier.new(val[0])}

  numeric : TINTEGER {result = Koona::AST::NInteger.new(val[0])}
          | TDOUBLE {result = Koona::AST::NFloat.new(val[0])}

  expr : ident TEQUAL expr {result = Koona::AST::NVariableAssignment.new(val[0], val[2], val[0])}
       | numeric
       | ident 
       | ident TLPAREN call_args TRPAREN {result = Koona::AST::NFunctionCall.new(val[0], val[2])}
       | expr comparison expr {result = Koona::AST::NBinaryOperator.new(val[0], val[1], val[2])}
       | TLPAREN expr TRPAREN {result = val[1]} # Check this later. Might be causing bugs.

  call_args : {result = Koona::AST::VariableList.new}
            | expr {result = Koona::AST::VariableList.new; result.variables << val[0]}
            | call_args TCOMMA expr {val[0].variables << val[2]}

  comparison : TCEQ | TCNE | TCLT | TCLE | TCGT | TCGE 
             | TPLUS | TMINUS | TMUL | TDIV
end

---- header
  require './lib/lexer'
  require './lib/ast'


---- inner
  def on_error(tok, val, vstack)
    $stderr.puts "Parse error on value: \"#{val.to_s}\"", "Stack: #{vstack.inspect}"
  end
  def parse(tokens)
    @tokens = tokens
    do_parse
  end

  def next_token
    @tokens.shift
  end
