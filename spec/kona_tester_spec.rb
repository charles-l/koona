require './parser.rb'

@evaluator = Kona.new

puts @evaluator.parse(File.open(ARGV[0]).read) if ARGV[0]
