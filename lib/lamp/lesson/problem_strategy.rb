# ~*~ encoding: utf-8 ~*~
require 'spirit'

module Lamp

  class Lesson

    class ProblemStrategy

      # Saves the problem's solution to a secret location for the game app to
      # retrieve for verification.
      # @todo TODO use the secure judge service if it's available.
      # @todo TODO set permissions for directory
      def self.create(path)
        klass = Class.new(Spirit::Render::Problem)
        Actions.directory path, mode: PERMISSIONS[:shared_dir]
        klass.instance_eval do
          def save!
            raise Lamp::Lesson::InvalidLessonError, 'Invalid problem encountered: %s' % name unless valid?
            solution = path + (id + Spirit::SOLUTION_EXT)
            Lamp.logger.info solution
            Lamp::Actions.write_file(solution, Marshal.dump(answer), 'wb+', Lamp::PERMISSIONS[:shared_file])
          end
        end
      end

    end

  end

end
