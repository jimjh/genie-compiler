# ~*~ encoding: utf-8 ~*~
require 'active_support/core_ext/object/blank'
require 'lamp/actions'
require 'lamp/lesson'

module Lamp

  module RPC

    # Provides implementation for the RPC interface. Refer to `lamp.thrift` for
    # details.
    class Handler

      attr_reader :started

      def initialize
        @started = Time.now
        Lesson.prepare_directories
      end

      # @return [String] 'pong!'
      def ping
        log_invocation
        'pong!'
      end

      # @return [Info] basic information about Lamp
      def info
        log_invocation
        Info.new uptime: uptime, threads: threads
      end

      # @return [LampStatus] status of request
      def create(git_url, lesson_path, callback, opts)
        log_invocation
        validate_create git_url, lesson_path, callback
        async_create    git_url, lesson_path, URI(callback), opts
      rescue => e
        Lamp.logger.error e
        raise e
      end

      # @return [LampStatus] status of request
      def remove(lesson_path, callback)
        log_invocation
        validate_remove lesson_path, callback
        async_remove    lesson_path, URI(callback)
      rescue => e
        Lamp.logger.error e
        raise e
      end

      private

      # @return [Hash] number of threads (+'total'+ and +'running'+)
      def threads
        { 'total'   => Thread.list.count,
          'running' => Thread.list.map(&:status).grep('run').count }
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

      def validate_presence_of(*args)
        case args.first
        when Hash
          pairs, trace = *args
          pairs.map { |pair| validate_presence_of(*pair, trace) }
        else
          key, value, trace = *args
          trace << "#{key} must not be blank" if value.blank?
        end
      end

      def validate_uri_format_of(value, trace)
        unless [URI::HTTP, URI::HTTPS].include? URI(value).class
          trace << "callback must be a valid http(s) URI"
        end
      end

      # Validates the parameters passed to create
      def validate_create(git_url, lesson_path, callback)
        trace = []
        validate_presence_of(
          { 'git_url' => git_url,
            'lesson_path' => lesson_path,
            'callback' => callback}, trace)
        validate_uri_format_of callback, trace
        raise RPCError, 'Validation failed: '+trace.join('; ') unless trace.empty?
      end

      # Invokes `create` on a separate thread.
      def async_create(git_url, lesson_path, callback, opts)
        async do
          Lamp::Lesson.create git_url, lesson_path, opts
          Net::HTTP.post_form(callback, { x: 'y' })
          Lamp.logger.debug 'create.cb  <- ' + lesson_path
        end
      end

      # Validates the parameters passed to rm
      def validate_remove(lesson_path, callback)
        trace = []
        validate_presence_of(
          { 'lesson_path' => lesson_path,
            'callback' => callback }, trace)
        validate_uri_format_of callback, trace
        raise RPCError, 'Validation failed: '+trace.join('; ') unless trace.empty?
      end

      # Invokes `rm` on a separate thread.
      def async_remove(lesson_path, callback)
        async do
          Lamp::Lesson.rm lesson_path
          Net::HTTP.post_form(callback, { x: 'y' })
          Lamp.logger.debug 'rm.cb  <- ' + lesson_path
        end
      end

      def async
        Thread.new do
          begin
            yield
          rescue => e
            Lamp.logger.error e
          end
        end
      end

    end

  end
end
