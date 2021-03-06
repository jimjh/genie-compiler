# ~*~ encoding: utf-8 ~*~
require './lib/lamp/version'

Gem::Specification.new do |gem|

  # NAME
  gem.name          = 'lamp'
  gem.version       = Lamp::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.required_ruby_version = '>= 1.9.2'

  # LICENSES
  gem.authors       = ['Jiunn Haur Lim']
  gem.email         = ['codex.is.poetry@gmail.com']
  gem.description   = %q{Compiles lessons for genie.}
  gem.summary       = %q{Compiles lessons for genie.}
  gem.homepage      = 'https://github.com/jimjh/genie-compiler'

  # PATHS
  gem.require_paths = %w[lib]
  gem.files         = %w[LICENSE README.md] +
                      Dir.glob('lib/**/*') +
                      Dir.glob('bin/**/*') +
                      Dir.glob('gen/**/*')
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }

  # DEPENDENCIES
  gem.add_dependency 'thrift',        '~> 0.9'
  gem.add_dependency 'thor',          '~> 0.16'
  gem.add_dependency 'activesupport', '~> 3.2'
  gem.add_dependency 'grit',          '~> 2.5'
  gem.add_dependency 'pry',           '~> 0.9'
  gem.add_dependency 'faraday',       '~> 0.8'
  gem.add_dependency 'spirit'

  gem.add_development_dependency 'mocha',        '~> 0.10'
  gem.add_development_dependency 'yard',         '~> 0.8'
  gem.add_development_dependency 'debugger-pry', '~> 0.1'
  gem.add_development_dependency 'rspec',        '~> 2.12'
  gem.add_development_dependency 'fuubar',       '~> 1.1'
  gem.add_development_dependency 'rake',         '~> 10.0'

end
