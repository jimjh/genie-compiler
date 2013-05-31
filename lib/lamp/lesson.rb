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

    attr_reader :repo, :name, :problems, :errors

    # Creates a new lesson from the given repo and name.
    # @param [Grit::Repo] repo          git repository
    # @param [String]     name          lesson name, used as subpath
    # @raise [InvalidLessonError] if the repository doesn't contain a valid
    #   manifest and index file.
    def initialize(repo, name)
      @repo, @name, @problems, @errors = repo, name, [], {}
      raise InvalidLessonError, errors unless valid?
      mf = File.expand_path Spirit::MANIFEST, repo.working_dir
      @manifest = Spirit::Manifest.load_file mf
    rescue Spirit::ManifestError => e
      errors[:manifest] = ['lesson.lamp.syntax', e.message]
      raise InvalidLessonError, errors
    end

    def public_paths
      { compiled_path: compiled_path,
        solution_path: solution_path }
    end

    def title
      @manifest[:title]
    end

    def description
      @manifest[:description]
    end

    private

    path_reader :source, :compiled, :solution

    def static_paths
      @manifest[:static_paths] || %w[images]
    end

    def valid?
      [[Spirit::MANIFEST, :manifest], [Spirit::INDEX, :index]].reduce(true) do |memo, pair|
        subpath, key = *pair
        valid = Actions.check_file? File.expand_path(subpath, repo.working_dir)
        errors[key] = ['lesson.lamp.missing'] unless valid
        memo and valid
      end
    end

  end

end
