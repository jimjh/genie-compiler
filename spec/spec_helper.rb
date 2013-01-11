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

# Redirects stderr and stdout to /dev/null.
def silence_output
  @orig_stderr = $stderr
  @orig_stdout = $stdout
  $stderr = File.new('/dev/null', 'w')
  $stdout = File.new('/dev/null', 'w')
end

# Replace stdout and stderr so anything else is output correctly.
def enable_output
  $stderr = @orig_stderr
  $stdout = @orig_stdout
  @orig_stderr = nil
  @orig_stdout = nil
end

require 'lamp'
require 'shared/repo_context'
require 'shared/file_helpers'
require 'shared/timeout_matcher.rb'
require 'shared/mode_matcher.rb'

RSpec.configure do |config|
  config.include Test::Matchers
  config.include Test::FileHelpers
  config.before(:all) { silence_output }
  config.after(:all)  { enable_output;  FileUtils.remove_entry_secure $root  }
end

Lamp.configure! root: $root = Dir.mktmpdir
Lamp.logger.level = Logger::FATAL
