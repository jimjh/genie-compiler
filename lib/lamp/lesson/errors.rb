# ~*~ encoding: utf-8 ~*~
module Lamp

  class Lesson

    # Raised if the given lesson repository does not contain the required files.
    class InvalidLessonError < Error
      attr_reader :errors
      def initialize(errors)
        @errors = errors
      end
    end

    # Raised if the worker is unable to obtain a lock on the lesson.
    class LockError < Error; end

    # Raised if the given lesson name is invalid.
    class NameError < Error; end

  end

end
