module Koona
  class Compiler
    def compile(ast)
      evaluator = Koona::Evaluator.new
      generator = Koona::Generator.new
      generator.generate(evaluator.scan_file(ast))
    end
  end
end
