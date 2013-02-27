# ~*~ encoding: utf-8 ~*~
require 'json'
require 'pathname'
require 'spirit/constants'

require 'lamp/git'

require 'lamp/lesson/errors'
require 'lamp/lesson/locks'
require 'lamp/lesson/clone'
require 'lamp/lesson/compile'
require 'lamp/lesson/create'
require 'lamp/lesson/remove'

module Lamp

  # A lesson begins as a git repository and ends as a set of compiled html
  # files.
  class Lesson

    extend Actions

    # Default options for public interface.
    DEFAULTS    = { branch: 'master' }

    class << self

      %w[source compiled lock solution].each do |name|
        m = (name.to_s + '_path').to_sym
        define_method(m) do |*args|
          subpath = args.first || '.'
          Pathname.new(Lamp.root) + name + subpath
        end
      end

      # Ensures that the source and compiled directories exist.
      # @return [void]
      def prepare_directories
        directory compiled_path, mode: PERMISSIONS[:public_dir]
        directory solution_path, mode: PERMISSIONS[:shared_dir]
        [source_path, lock_path].each do |p|
          directory p, mode: PERMISSIONS[:private_dir]
        end
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
    #   manifest and index file.
    def initialize(repo, name)
      @repo, @name = repo, name
      manifest_file = File.expand_path Spirit::MANIFEST, repo.working_dir
      Actions.check_file manifest_file
      Actions.check_file File.expand_path(Spirit::INDEX, repo.working_dir)
      @manifest = Spirit::Manifest.load_file manifest_file
    end

    private

    path_reader :source, :compiled, :solution

    def static_paths
      @manifest[:static_paths] || %w(images)
    end

  end

end
