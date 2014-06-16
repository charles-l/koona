all:
	rex koona.rex -o lexer.rb
	racc koona.y -o parser.rb
	ruby spec/koona_tester_spec.rb spec/test.kn
