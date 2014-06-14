require './parser.rb'

@evaluator = Kona.new

puts @evaluator.scan_str("{x=3+4
                          x=x+2}")
