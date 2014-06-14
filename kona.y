class Kona
  token TIDENTIFIER TDOUBLE TINTEGER
  token TCEQ TCNE TCLT TCLE TCGT TCGE TEQUAL
  token TLPAREN TRPAREN TLBRACE TRBRACE TCOMMA TDOT
  token TPLUS TMINUS TMUL TDIV

  start program
rule
  program : stmts {programBlock = val[0]}
  stmts : stmt {result = NBlock.new} | stmts stmt
  stmt : var_decl | expr | block
  block : TLBRACE stmts TRBRACE {result = val[1]}
  var_decl : ident TEQUAL expr {}
  ident : TIDENTIFIER
  numeric : TINTEGER | TDOUBLE
  expr : ident TEQUAL expr
       | numeric
       | ident
       | expr comparison expr
  comparison : TCEQ | TCNE | TCLT | TCLE | TCGT | TCGE 
             | TPLUS | TMINUS | TMUL | TDIV
end

---- header
  require './node.rb'
  require './lexer.rb'
  programBlock = NBlock.new

---- inner
  def parse(input)
    scan_str(input)
  end
