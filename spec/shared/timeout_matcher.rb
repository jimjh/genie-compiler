# ~*~ encoding: utf-8 ~*~
require 'timeout'
module Test

  module Matchers

    class Timeout

      attr_reader :threshold

      def initialize(threshold)
        @threshold = threshold
      end

      def description
        "timeout after #{threshold} seconds"
      end

      def failure_message_for_should
        "expected operation to take longer than #{threshold} seconds"
      end

      def failure_message_for_should_not
        "expected operation to take no more than #{threshold} seconds"
      end

      def matches?(given_proc)
        begin
          ::Timeout::timeout(threshold) { given_proc.call }
        rescue ::Timeout::Error
          true
        else false
        end
      end

    end

    def timeout(threshold)
      Timeout.new threshold
    end

  end

end
