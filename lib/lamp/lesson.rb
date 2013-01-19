# ~*~ encoding: utf-8 ~*~
require 'json'
require 'pathname'
require 'spirit/constants'

require 'lamp/lesson/errors'
require 'lamp/lesson/locks'
require 'lamp/lesson/clone'
require 'lamp/lesson/compile'
require 'lamp/lesson/create'
require 'lamp/lesson/remove'
require 'lamp/git'

module Lamp

  # A lesson begins as a git repository and ends as a set of compiled html
  # files. Note that +name+ is assumed to be safe (w.r.t. directory traversal
  # attacks.)
  class Lesson
    extend  Actions
    include Actions

    # Default options for public interface.
    DEFAULTS    = { branch: 'master' }

    class << self

      # Path to lesson sources.
      # @return [Pathname] path
      def source_path(name='.')
        Pathname.new(Lamp.settings.root) + 'source' + name
      end

      # Path to compiled lessons.
      # @return [Pathname] path
      def compiled_path(name='.')
        Pathname.new(Lamp.settings.root) + 'compiled' + name
      end

      # Path to lesson solutions.
      # @return [Pathname] path
      def solution_path(name='.')
        Pathname.new(Lamp.settings.root) + 'solution' + name
      end

      # Path to lesson locks.
      # @return [Pathname] path
      def lock_path(name='.')
        Pathname.new(Lamp.settings.root) + 'lock' + name
      end

      # Ensures that the source and compiled directories exist.
      # @return [void]
      def prepare_directories
        directory compiled_path, mode: PERMISSIONS[:public_dir]
        [source_path, lock_path].each { |p| directory p, mode: PERMISSIONS[:private_dir] }
        directory solution_path, mode: PERMISSIONS[:shared_dir]
      end

      private

      # Dynamically defines getter methods for +source_path+, +compiled_path+
      # etc.
      # @param  [Array] names               array of path names
      # @return [void]
      def path_reader(*names)
        names.each do |name|
          m = (name.to_s + '_path').to_sym
          define_method(m) { Lesson.public_send m, self.name }
        end
      end

      # Ensures that the given name is safe for use in a path.
      # @param [String] name
      # @raise [NameError] if the given name is not safe
      def ensure_safe_name(name)
        lesson_path = source_path name
        unless descends_from? source_path, lesson_path
          raise NameError.new '%s is not a safe name.' % name
        end
      end

    end

    attr_reader :repo, :name

    # Creates a new lesson from the given repo and name.
    # @param [Grit::Repo] repo          git repository
    # @param [String]     name          lesson name, used as subpath
    # @raise [InvalidLessonError] if the repository doesn't contain a valid
    #   +manifest.json+ and a valid +index.md+.
    def initialize(repo, name)
      @repo, @name = repo, name
      manifest_file = File.expand_path(Spirit::MANIFEST, repo.working_dir)
      check_file manifest_file
      check_file File.expand_path(Spirit::INDEX, repo.working_dir)
      @manifest = Spirit::Manifest.load_file manifest_file
    end

    private
    path_reader :source, :compiled, :solution

    def static_paths
      @manifest[:static_paths] || %w(images)
    end

  end

end
