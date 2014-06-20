module Koona
  class Compiler
    def compile(input)
      lexer = Koona::Lexer.new
      parser = Koona::Parser.new
      ast = parser.parse(lexer.scan_file(input))
      puts ast
    end
  end
end
