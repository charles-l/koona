class Koona
  token TIDENTIFIER TDOUBLE TINTEGER
  token TCEQ TCNE TCLT TCLE TCGT TCGE TEQUAL
  token TLPAREN TRPAREN TLBRACE TRBRACE TCOMMA TDOT
  token TPLUS TMINUS TMUL TDIV

  start program
rule
  program : stmts {programBlock = NBlock.new}
  stmts : stmt {result = NBlock.new; result.statements << val[0]} 
        | stmts stmt {val[0].statements << val[1]}
  stmt : expr
       | block 
       | func_decl
  block : TLBRACE TRBRACE {result = NBlock.new}
        | TLBRACE stmts TRBRACE {result = NBlock.new; result.statements << val[1]}
  func_decl : ident TLPAREN func_decl_args TRPAREN block 
            { result = NFunctionDeclaration.new(val[0], val[2], val[4])}
  func_decl_args : {VariableList.new([])}
                 | ident {result = VariableList.new; result.variables << val[0]}
                 | func_decl_args TCOMMA ident {val[0].variables << val[2]}
  ident : TIDENTIFIER {result = NIdentifier.new(val[0])}
  numeric : TINTEGER {result = NInteger.new(val[0])}
          | TDOUBLE {result = NFloat.new(val[0])}
  expr : ident TEQUAL expr {result = NVariableDeclaration.new(val[0], val[2])}
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
  require './node.rb'
  require './lexer.rb'
  require './node.rb'
  programBlock = NBlock.new

---- inner
  def parse(input)
    do_parse
  end
  def on_error(tok, val, vstack)
    $stderr.puts "Parse error on value: \"#{val.to_s}\"", "Stack: #{vstack.inspect}"
  end
