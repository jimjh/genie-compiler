# ~*~ encoding: utf-8 ~*~
require 'json'
require 'pathname'
require 'spirit/constants'

require 'lamp'
require 'lamp/actions'
require 'lamp/git'

require 'lamp/lesson/errors'
require 'lamp/lesson/helpers'
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
    extend Helpers::Map
    include Helpers::Paths

    # Ensures that the source and compiled directories exist with the
    # appropriate permissions.
    # @return [void]
    def self.prepare_directories
      directory compiled_path, mode: PERMISSIONS[:public_dir]
      directory solution_path, mode: PERMISSIONS[:shared_dir]
      [source_path, lock_path].each do |p|
        directory p, mode: PERMISSIONS[:private_dir]
      end
    end

    # Ensures that the given name is safe for use in a path.
    # @param [String] name
    # @raise [NameError] if the given name is not safe
    def self.ensure_safe_name(name)
      lesson_path = source_path name
      unless descends_from? source_path, lesson_path
        raise NameError, '%s is not a safe name.' % name, caller
      end
    end
    private_class_method :ensure_safe_name

    attr_reader :repo, :name, :problems, :errors
    map :title, :description, :static_paths, to: :manifest

    # Creates a new lesson from the given repo and name.
    # @param [Grit::Repo] repo          git repository
    # @param [String]     name          lesson name, used as subpath
    # @raise [InvalidLessonError] if the repository doesn't contain a valid
    #   manifest and index file.
    def initialize(repo, name)
      @repo, @name, @problems, @errors = repo, name, [], {}
      raise InvalidLessonError, errors unless valid?
      @manifest = Spirit::Manifest.load_file in_repo Spirit::MANIFEST
      @manifest = DEFAULT_MANIFEST.dup.deep_merge @manifest
    rescue Spirit::ManifestError => e
      errors[:manifest] = ['lesson.lamp.syntax', e.message]
      raise InvalidLessonError, errors, caller
    end

    private

    def valid?
      [:manifest, :index].reduce(true) do |memo, type|
        file  = Spirit.const_get type.upcase
        valid = Actions.check_file? in_repo file
        errors[type] = ['lesson.lamp.missing'] unless valid
        memo and valid
      end
    end

  end

end
