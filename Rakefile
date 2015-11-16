task :default => :all

task :all do
	`racc lib/koona.y -o lib/parser.rb`
end

task :test => :all do
	`bin/koona compile test.kn --debug`
	`ruby tests.rb`
end
