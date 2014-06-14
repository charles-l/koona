class Kona

macro
  BLANK [\ \t\n]
rule
  {BLANK} # nothing
  [a-zA-Z_][a-zA-Z0-9_]*  {[:TIDENTIFIER, text]}
  [0-9]+\.[0-9]*          {[:TFLOAT, text.to_f]}
  [0-9]+                  {[:TINTEGER, text.to_i]}
  =                     {[:TEQUAL, text]}
  ==                    {[:TCEQ, text]}
  \!=                    {[:TCNE, text]}
  \<                     {[:TCLT, text]}
  \<=                    {[:TCLE, text]}
  \>                     {[:TCGT, text]}
  \>=                    {[:TCGE, text]}
  \(                     {[:TLPAREN, text]}
  \)                     {[:TRPAREN, text]}
  \{                     {[:TLBRACE, text]}
  \}                     {[:TRBRACE, text]}
  \.                     {[:TDOT, text]}
  \,                     {[:TCOMMA, text]}
  \+                     {[:TPLUS, text]}
  \-                     {[:TMINUS, text]}
  \*                    {[:TMUL, text]}
  \/                     {[:TDIV, text]}
  .                       { return "Unexpected character!"}
inner
  def tokenize(code)
    scan_setup(code)
    tokens = []
    while token = next_token
      tokens << token
    end
    tokens
  end
end
