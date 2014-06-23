module Koona
  class Compiler
    def compile(input, debug=false)
      lexer = Koona::Lexer.new
      parser = Koona::Parser.new
      generator = Koona::Generator.new
      ast = parser.parse(lexer.scan_file(input))
      puts ast if debug
      generator.generate(ast)
    end
  end
end
