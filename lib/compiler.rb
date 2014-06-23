module Koona
  class Compiler
    def compile(input, debug=false)
      lexer = Koona::Lexer.new
      parser = Koona::Parser.new
      generator = Koona::Generator.new
      ast = parser.parse(lexer.scan_file(input))
      if debug then
        puts '-' * 40
        puts 'AST Debug info'
        puts '-' * 40
        puts ast
      end
      generator.generate(ast)
    end
  end
end
