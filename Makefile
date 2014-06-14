all:
	rex kona.rex -o lexer.rb
	racc kona.y -o parser.rb
	ruby spec/kona_tester_spec.rb
