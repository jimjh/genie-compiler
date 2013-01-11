# ~*~ encoding: utf-8 ~*~
module Test

  module Matchers

    class Mode

      attr_reader :mode

      def initialize(mode)
        @mode = mode
      end

      def description
        'have permissions set to 0%o' % mode
      end

      def failure_message_for_should
        'expected file or directory to have permissions set to 0%o' % mode
      end

      def failure_message_for_should_not
        'expected file or directory to not have permissions set to 0%o' % mode
      end

      def matches?(file)
        (octal File.stat(file).mode) =~ /#{octal mode}$/
      end

      def octal(int)
        '%o' % int
      end

    end

    def have_mode(mode)
      Mode.new mode
    end

  end

end
