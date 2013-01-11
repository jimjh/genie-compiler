# ~*~ encoding: utf-8 ~*~
# This script is a bad boy. It monkey patches {Aladdin::Render::Problem} so
# that the +save!+ method does something else. Since all of Aladdin's code is
# open-source but all of Lamp is closed-source, this allows me to implement
# custom behavior for the worker that the public doesn't see. However, since I
# wrote both gems, you would think I have a better solution.
#
# Guess who's not getting the Best Coding Practices award.
require 'aladdin/render'

module Aladdin

  module Render

    class Problem < Template

      # Saves the problem's solution to a secret location for the game app to
      # retrieve for verification.
      # @todo TODO use the secure judge service if it's available.
      # @todo TODO set permissions
      def save!(name)
        raise Lamp::Lesson::InvalidLessonError, 'Invalid problem encountered: %s' % name unless valid?
        solution = id + Aladdin::SOLUTION_EXT
        path = Lamp::Lesson.solution_path(name) + solution
        Lamp::Actions.write_file(path, Marshal.dump(answer), 'wb+', Lamp::PERMISSIONS[:shared_file])
      end

    end

  end

end
