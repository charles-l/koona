require './parser.rb'
require './generator.rb'

@evaluator = Koona.new
@generator = Generator.new

if ARGV[0]
  puts @evaluator.scan_file(ARGV[0]).statements.inspect
  puts @generator.generate(@evaluator.scan_file(ARGV[0]))
end
