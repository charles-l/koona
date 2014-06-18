all:
	racc lib/koona.y -o lib/parser.rb
	bin/koona test.kn
