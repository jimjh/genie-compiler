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
  ROOT   = Pathname.new File.dirname(__FILE__)
  OUTPUT = StringIO.new
end

$:.unshift Test::ROOT + '..' + 'lib'

require 'shared/global_context'
require 'shared/repo_context'
require 'shared/file_helpers'
require 'shared/timeout_matcher.rb'
require 'shared/mode_matcher.rb'

RSpec.configure do |config|

  config.include Test::GlobalContext
  config.include Test::Matchers
  config.include Test::FileHelpers

  config.mock_framework = :mocha
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true

  config.before(:suite) { Lamp.reset_logger 'log-file' => Test::OUTPUT }
  config.before(:each)  { Lamp.stubs(:reset_logger) }
  config.after(:each)   { Test::OUTPUT.truncate 0 }

  # config.after :suite do
  #  FileUtils.remove_entry_secure Lamp.settings.root
  # end

end

