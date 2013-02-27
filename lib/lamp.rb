# ~*~ encoding: utf-8 ~*~
require 'pathname'
require 'thrift'
require 'active_support/core_ext/hash'

require 'lamp/version'
require 'lamp/config'
require 'lamp/errors'
require 'lamp/logger'
require 'lamp/support'
# require 'lamp/actions'

module Lamp
  class << self

    attr_reader :logger

    # @option opts [String] log-file  ({Lamp::LOG_FILE})
    # @option opts [String] log-level ({Lamp::LOG_LEVEL})
    def reset_logger(opts={})
     @logger = Logger.new(opts['log-file'] || LOG_FILE)
     @logger.level = opts['log-level'] || LOG_LEVEL
     @logger.formatter = Logger::Formatter.new
     @logger.info "Lamp v#{VERSION}"
    end

    # Starts a RPC server. See {Lamp::Server} for options.
    def server(opts={})
      require 'lamp/server'
      reset_logger opts
      Server.new(opts).serve.value
    rescue Interrupt
      logger.info 'Extinguished.'
    end

    # Starts a client and invokes the given command. If a command is not
    # provided, starts a pry console. See {Lamp::Client} for options.
    # @param [String] cmd       RPC command to invoke
    # @param [Array]  argv      parameters for command
    # @return [void]
    def client(cmd=nil, argv=[], opts={})
      require 'lamp/client'
      reset_logger opts
      client = Client.new(opts)
      results = invoke client, cmd, argv
      logger.info "Response: #{results.inspect}"
    end

    private

    def invoke(client, cmd, argv)
      if cmd.nil?
        require 'pry'
        client.invoke { pry }
      else client.invoke { public_send(cmd, *argv) }
      end
    end

  end

end

  # include Actions
  # extend self

  # Loads configuration options from +file+. This is not thread-safe, and
  # should only be called at the beginning.
  # @param [String, Hash] arg          path to configuration file, or hash
  #                                    containing options
  # @return [void]
  # def configure!(arg=CONFIG_FILE)
  #   case arg
  #   when String
  #     check_file     arg
  #     settings.load! arg
  #   else settings.load! arg
  #   end
  #   reset_logger
  #   Lesson.prepare_directories
  # end


# end

# require 'lamp/lesson'
