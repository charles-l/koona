class Koona::Parser
  token TIDENTIFIER TDOUBLE TINTEGER
  token TCEQ TCNE TCLT TCLE TCGT TCGE TEQUAL
  token TLPAREN TRPAREN TLBRACE TRBRACE TCOMMA TDOT
  token TPLUS TMINUS TMUL TDIV
  token TRETURN

  start program
rule
  program : stmts {programBlock = NBlock.new; programBlock.statements << val[0]}
  stmts : stmt {result = NBlock.new; result.statements << val[0]} 
        | stmts stmt {val[0].statements << val[1]}
  stmt : expr
       | block 
       | func_decl
       | var_decl
  block : TLBRACE TRBRACE {result = NBlock.new}
        | TLBRACE stmts TRBRACE {result = NBlock.new; result.statements << val[1]}
  var_decl : ident ident TEQUAL expr {result = NVariableDeclaration.new(val[0], val[1], val[3])}
  func_decl : ident ident TLPAREN func_decl_args TRPAREN block 
            { result = NFunctionDeclaration.new(val[0], val[1], val[3], val[5])}
  func_decl_args : {VariableList.new([])}
                 | ident ident {result = VariableList.new; result.variables << FunctionVar.new(val[0], val[1])}
                 | func_decl_args TCOMMA ident ident {val[0].variables << FunctionVar.new(val[2], val[3])}
  ident : TIDENTIFIER {result = NIdentifier.new(val[0])}
  numeric : TINTEGER {result = NInteger.new(val[0])}
          | TDOUBLE {result = NFloat.new(val[0])}
  expr : TRETURN expr {result = NReturn.new(val[1])}
       | ident TEQUAL expr {result = NVariableAssignment.new(val[0], val[2])}
       | numeric
       | ident 
       | ident TLPAREN call_args TRPAREN {result = NFunctionCall.new(val[0], val[2])}
       | expr comparison expr {result = NBinaryOperator.new(val[0], val[1], val[2])}
       | TLPAREN expr TRPAREN {result = val[1]}
  call_args : {result = VariableList.new}
            | expr {result = VariableList.new; result.variables << val[0]}
            | call_args TCOMMA expr {val[0].variables << val[2]}
  comparison : TCEQ | TCNE | TCLT | TCLE | TCGT | TCGE 
             | TPLUS | TMINUS | TMUL | TDIV
end

---- header
  require './lib/node.rb'
  require './lib/lexer.rb'


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
