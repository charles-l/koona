all:
	rex lib/koona.rex -o lib/lexer.rb
	racc lib/koona.y -o lib/parser.rb
