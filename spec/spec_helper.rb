# ~*~ encoding: utf-8 ~*~
require 'rubygems'
require 'bundler/setup'
require 'tmpdir'
require 'rspec'

begin Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems."
  exit e.status_code
end

module Test
  ROOT = Pathname.new File.dirname(__FILE__)
end

$:.unshift Test::ROOT + '..' + 'lib'

require 'lamp'
require 'shared/repo_context'
require 'shared/file_helpers'
require 'shared/timeout_matcher.rb'
require 'shared/mode_matcher.rb'

RSpec.configure do |config|

  config.include Test::Matchers
  config.include Test::FileHelpers

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.before :suite do
    Lamp.configure! root: Dir.mktmpdir
    Lamp.logger.level = Logger::FATAL
  end

  config.after :suite do
    FileUtils.remove_entry_secure Lamp.settings.root
  end

end

