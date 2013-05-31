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
        'expected file or directory to have permissions set to 0%o, but was %o' %
          [mode, @actual]
      end

      def failure_message_for_should_not
        'expected file or directory to not have permissions set to 0%o' % mode
      end

      def matches?(file)
        @actual = File.stat(file).mode
        (octal @actual) =~ /#{octal mode}$/
      end

      def octal(int)
        '%o' % int
      end

    end

    def have_mode(type)
      Mode.new type
    end

    def have_mode_of(type)
      Mode.new Lamp::PERMISSIONS[type]
    end

  end
end
