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
require 'shared/file_context'
require 'shared/timeout_matcher.rb'

Lamp.logger.level = Logger::FATAL

RSpec.configure do |config|
  config.include Test::Matchers
  config.before(:all) { silence_output }
  config.after(:all)  { enable_output  }
end
