module Koona
  class Compiler
    def compile(input)
      lexer = Koona::Lexer.new
      parser = Koona::Parser.new
      generator = Koona::Generator.new
      puts generator.generate(parser.parse(lexer.scan_file(input)))
    end
  end
end
