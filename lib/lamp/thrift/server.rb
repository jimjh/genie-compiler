# ~*~ encoding: utf-8 ~*~
require 'lamp/thrift/gen'
require 'lamp/thrift/handler'

module Lamp

  # Contains, configures, and controls the Thrift RPC server.
  class Server

    attr_reader :port, :socket, :thread

    # Number of seconds to wait while server is starting up
    SPIN = 0.1

    # @option opts [Fixnum] port     port number
    def initialize(opts={})
      Lamp.logger.info 'Initializing Lamp server ...'
      @port     = opts['port'] || PORT
      @socket   = Thrift::ServerSocket.new(opts['host'] || HOST, port)
      processor = Processor.new Handler.new
      factory   = Thrift::BufferedTransportFactory.new
      @server   = Thrift::ThreadPoolServer.new(processor, socket, factory)
    end

    # Starts the Thrift RPC server and returns the server thread. Note that
    # while the server may spawn new threads, the returned thread completes
    # only after the server has stopped.
    # @return [Thread] thread         main thread for RPC server
    def serve
      Lamp.logger.info 'Starting Lamp service ...'
      @thread = Thread.new { @server.serve }
      sleep SPIN while @thread.alive? and not socket.handle
      @port = socket.handle.addr[1] and Lamp.logger.info status if @thread.alive?
      @thread
    end

    # @return [String] status message
    def status
      if @thread.alive?
        if socket.handle then "Lamp is listening on port #{port}."
        else 'Lamp is lighting up.'
        end
      else 'Lamp has been extinguished.'
      end
    end

  end

end
