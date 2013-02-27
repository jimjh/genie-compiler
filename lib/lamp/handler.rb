# ~*~ encoding: utf-8 ~*~
module Lamp

  # Provides implementation for the RPC interface. Refer to `lamp.thrift` for
  # details.
  class Handler

    attr_reader :started

    def initialize
      @started = Time.now
    end

    # @return [String] 'pong!'
    def ping
      log_invocation
      'pong!'
    end

    # @return [LampInfo] basic information about Lamp
    def info
      log_invocation
      LampInfo.new uptime: uptime, threads: threads
    end

    private

    # @return [Hash] number of threads (+'total'+ and +'running'+)
    def threads
      { 'total'   => Thread.list.count,
        'running' => Thread.list.map(&:status).grep('run').count
      }
    end

    # @return [Float] number of seconds since server launch
    def uptime
      Time.now - started
    end

    # Logs the caller of this method.
    def log_invocation
      if Lamp.logger.debug?
        Lamp.logger.debug 'rpc -> ' + caller[0][/`([^']*)'/, 1]
      end
    end

  end

end
