module Koona
  class Compiler
    def compile(input)
      lexer = Koona::Lexer.new
      parser = Koona::Parser.new
      puts parser.parse(lexer.scan_file(input))
    end
  end
end
