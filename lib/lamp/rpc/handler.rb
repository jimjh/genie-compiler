# ~*~ encoding: utf-8 ~*~
require 'active_support/core_ext/object/blank'
require 'faraday'
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
        async_create    git_url, lesson_path, callback, opts
      rescue => e
        Lamp.logger.error e
        raise e
      end

      # @return [LampStatus] status of request
      def remove(lesson_path, callback)
        log_invocation
        validate_remove lesson_path, callback
        async_remove    lesson_path, callback
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
        Lamp.logger.debug { 'rpc -> ' + log_caller(4) }
      end

      def log_success(*args)
        Lamp.logger.debug { log_caller(5) + ' -> ' + args.join }
      end

      def log_failure
        Lamp.logger.warn { log_caller(5) + ' x> ' + args.join }
      end

      def log_caller(nested)
        caller[nested][/`.*'/][1..-2].split.last
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
        async(callback) do |url|
          begin
            lesson  = Lamp::Lesson.create git_url, lesson_path, opts
            payload = lesson.public_paths.dup
            payload[:problems] = lesson.problems.map do |p|
              { digest: Base64.urlsafe_encode64(p[:digest]),
                solution: Base64.urlsafe_encode64(p[:solution]) }
            end
            payload[:title] = lesson.title
            payload[:description] = lesson.description
          rescue Lamp::Error => e
            post_failure lesson_path, url, e
          else
            post_success lesson_path, url, payload
          end
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
        async(callback) do |url|
          begin
            Lamp::Lesson.rm lesson_path
          rescue Lamp::Error => e
            post_failure lesson_path, url, e
          else
            post_success lesson_path, url, {}
          end
        end
      end

      def async(*args)
        Thread.new do
          begin yield(*args)
          rescue => e
            Lamp.logger.error e
          end
        end
      end

      def post_success(lesson_path, url, payload)
        Faraday.post url, { status: 200, payload: payload }
        log_success lesson_path
      end

      def post_failure(lesson_path, url, e)
        case e
        when Lamp::Lesson::InvalidLessonError
          Faraday.post url, { status: 422, errors: e.errors }
        else
          Faraday.post url, { status: 502, message: e.message }
        end
        log_failure lesson_path
      end

    end

  end
end
