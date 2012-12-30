# ~*~ encoding: utf-8 ~*~
require 'json'
require 'pathname'
require 'aladdin/config'

require 'lamp/lesson/errors'
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

    # Name of index file.
    INDEX_FILE  = 'index.md'

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

      private

      # Ensures that the source and compiled directories exist.
      # @return [Void]
      def prepare_directories
        FileUtils.mkdir_p source_path
        FileUtils.mkdir_p compiled_path
        FileUtils.mkdir_p solution_path
      end

    end

    prepare_directories
    attr_reader :repo, :name

    # Creates a new lesson from the given repo.
    # @param [Grit::Repo] repo          git repository
    # @param [String]     name          lesson name
    # @raise [InvalidLessonError] if the repository doesn't contain a valid
    #   +manifest.json+ and a valid +index.md+.
    # @todo TODO actually parse manifest.json
    # @todo TODO move {INDEX_FILE} to Aladdin
    def initialize(repo, name)
      @repo, @name = repo, name
      unless File.exist? File.expand_path(Aladdin::Config::FILE, repo.working_dir)
        raise MissingManifestError.new repo.working_dir
      end
      unless File.exist? File.expand_path(INDEX_FILE, repo.working_dir)
        raise MissingIndexError.new repo.working_dir
      end
      @manifest = Aladdin::Config.new @repo.working_dir
    end

    private

    # @return [Pathname] source path
    def source_path; Lesson.source_path name end

    # @return [Pathname] compiled path
    def compiled_path; Lesson.compiled_path name end

    # @return [Pathname] solution path
    def solution_path; Lesson.solution_path name end

  end

end
