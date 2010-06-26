Gem::Specification.new do |s|

  s.platform = Gem::Platform::RUBY
  s.name = 'css_primer'
  s.version = '0.2'
  s.summary = 'CSS Primer for markup files'
  s.description = 'Takes in a markup file (html/xml) and creates a CSS file with a reference to classes/ids.'

  s.required_ruby_version = '>= 1.8.6'

  s.author = 'Brent Lintner'
  s.email = 'brent.lintner@gmail.com'
  s.homepage = 'http://github.com/brentlintner/css_primer'

  s.files = Dir['bin/*', 'css_primer.gemspec', 'CHANGELOG', 'README', 'lib/*'].to_a

  s.has_rdoc         = true
  s.extra_rdoc_files = %w( README )
  s.rdoc_options.concat ['--main',  'README']

  s.executables = ["css_primer"]
  s.require_path = "lib"

end




