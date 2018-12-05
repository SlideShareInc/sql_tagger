Gem::Specification.new do |s|
  s.name = 'sql_tagger'
  s.version = IO.read('VERSION').chomp
  s.authors = ['Toby Hsieh']
  s.homepage = 'https://github.com/SlideShareInc/sql_tagger'
  s.summary = 'Stack trace comments for SQL queries'
  s.description = 'sql_tagger inserts stack trace comments into SQL queries.'
  s.license = 'MIT'

  s.add_development_dependency('rspec', '~> 3.4')

  s.add_development_dependency('appraisal', '~> 2.1.0')
  s.add_development_dependency('mysql2')
  s.add_development_dependency('pg')

  s.files = ['MIT-LICENSE', 'README.md', 'VERSION', 'sql_tagger.gemspec'] +
    Dir.glob('lib/**/*')

  s.test_files = Dir.glob('spec/**/*')
end
