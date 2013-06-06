# ~*~ encoding: utf-8 ~*~
require 'thor'
require 'lamp'

module Lamp

  # Exposes a command-line interface using Thor.
  class Cli < Thor

    class_option :'log-file',  type: :string,  default: nil
    class_option :'log-level', type: :numeric, default: LOG_LEVEL
    class_option :'root',      type: :string,  default: nil

    desc 'server', 'start a RPC server'
    option :port, type: :numeric, default: PORT
    def server
      ::Lamp.server options
    end

    desc 'client COMMAND', 'use client to invoke remote RPC call'
    option :host, type: :string, default: HOST
    option :port, type: :numeric, required: true
    def client
      ::Lamp.client args.shift, args, options
    end

  end

end
