# ~*~ encoding: utf-8 ~*~
require 'pathname'
require 'thrift'
require 'spirit'

require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/module/attribute_accessors'

require 'lamp/version'
require 'lamp/config'
require 'lamp/errors'
require 'lamp/logger'

module Lamp

  # Logger - configure using Lamp#reset_logger.
  mattr_reader :logger
  @@logger = Logger.new LOG_FILE

  # Path to root directory - configure using Lamp#reset_root.
  mattr_reader :root
  @@root = ROOT

  # @option opts [String] log-file  ({Lamp::LOG_FILE})
  # @option opts [String] log-level ({Lamp::LOG_LEVEL})
  # @return [void]
  def self.reset_logger(opts={})
    @@logger = Logger.new(opts['log-file'] || LOG_FILE)
    @@logger.level = opts['log-level'] || LOG_LEVEL
    @@logger.formatter = Logger::Formatter.new
    @@logger.info "Lamp v#{VERSION}"
    Spirit.reset_logger(opts['log-file'] || LOG_FILE)
  end

  # @option opts [String] path to root
  # @return [void]
  def self.reset_root(opts={})
    @@root = opts['root'] || ROOT
  end

  # Starts a RPC server. See {Lamp::Server} for options.
  # @return [void]
  def self.server(opts={})
    reset_root   opts
    reset_logger opts
    require 'lamp/rpc/server'
    RPC::Server.new(opts).serve.value
  rescue Interrupt
    logger.info 'Extinguished.'
  end

  # Starts a client and invokes the given command. If a command is not
  # provided, starts a pry console. See {Lamp::Client} for options.
  # @param [String] cmd       RPC command to invoke
  # @param [Array]  argv      arguments for command
  # @return [void]
  def self.client(cmd=nil, argv=[], opts={})
    reset_logger opts
    require 'lamp/rpc/client'
    client = RPC::Client.new(opts)
    results = invoke client, cmd, argv
    logger.info "Response: #{results.inspect}"
  end

  def self.invoke(client, cmd, argv)
    if cmd.nil?
      require 'pry'
      client.invoke { pry }
    else client.invoke { public_send(cmd, *argv) }
    end
  end
  private_class_method :invoke

end
