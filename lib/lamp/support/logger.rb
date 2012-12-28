# ~*~ encoding: utf-8 ~*~
require 'active_support/core_ext/logger'

module Lamp

  module Support

    # Provides a convenient global logger.
    # @example
    #   class X
    #     include Logger
    #     def x; logger.info 'hey'; end
    #   end
    module Logger

      # @return [Logger] logger
      def logger
        @__logger__ ||= ::Logger.new(Lamp::LOG_OUTPUT)
      end

    end

  end

end
