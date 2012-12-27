# ~*~ encoding: utf-8 ~*~
require './lib/lamp/version'

Gem::Specification.new do |gem|

  # NAME
  gem.name          = 'lamp'
  gem.version       = Lamp::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.required_ruby_version = '>= 1.9.2'

  # LICENSES
  gem.license       = 'MIT'
  gem.authors       = ['Jiunn Haur Lim']
  gem.email         = ['codex.is.poetry@gmail.com']
  gem.description   = %q{Compiles lessons.}
  gem.summary       = %q{Compiles lessons.}
  gem.homepage      = 'https://github.com/jimjh/genie-worker'

  # PATHS
  gem.require_paths = %w[lib]
  gem.files         = %w[LICENSE README.md] +
                      Dir.glob('lib/**/*') +
                      Dir.glob('bin/**/*')
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }

end
