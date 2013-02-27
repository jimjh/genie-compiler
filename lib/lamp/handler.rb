# ~*~ encoding: utf-8 ~*~
require 'active_support/core_ext/object/blank'
require 'lamp/actions'
require 'lamp/lesson'

module Lamp

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

    # @return [LampInfo] basic information about Lamp
    def info
      log_invocation
      LampInfo.new uptime: uptime, threads: threads
    end

    # @return [LampStatus] status of request
    def create(git_url, lesson_path, callback, opts)
      log_invocation
      trace = []
      validate_create git_url, lesson_path, callback, trace
      async_create    git_url, lesson_path, URI(callback), opts
      LampStatus.new code: LampCode::SUCCESS, trace: trace
    rescue => e
      trace << 'Request failed: %s' % e.message
      LampStatus.new code: LampCode::FAILURE, trace: trace
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

    # Validates the parameters passed to create
    def validate_create(git_url, lesson_path, callback, trace)
      valid = { 'git_url' => git_url,
                'lesson_path' => lesson_path,
                'callback' => callback }.reduce(true) do |memo, pair|
        memo &&= validate_presence_of(*pair, trace)
      end
      raise Error, 'Validation failed.' unless valid
    end

    def validate_presence_of(key, value, trace)
      return true unless value.blank?
      trace << "#{key} must not be blank."
      false
    end

    # Invokes `create` on a separate thread.
    def async_create(git_url, lesson_path, callback, opts)
      Thread.new do
        begin
          Lamp::Lesson.create git_url, lesson_path, opts
          Net::HTTP.post_form(callback, { x: 'y' })
          Lamp.logger.debug 'cb  <- ' + lesson_path
        rescue => e
          Lamp.logger.error e
        end
      end
    end

  end

end
