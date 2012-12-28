# ~*~ encoding: utf-8 ~*~
require 'lamp/lesson/errors'
require 'lamp/git'
require 'aladdin/config'

module Lamp

  # A lesson begins as a git repository and ends as a set of compiled html
  # files.
  class Lesson

    # Name of index file.
    INDEX_FILE = 'index.md'

    # Default options for public interface.
    DEFAULTS = {
      branch:       'master',
    }

    class << self

      # Path to lesson sources.
      def source_path
        File.join(Lamp.settings.root, 'source')
      end

      # Path to compiled lessons.
      def compiled_path
        File.join(Lamp.settings.root, 'compiled')
      end

      # Clones the git repository at the given URL to
      # +{ROOT}/source/{LESSON_PATH}+.
      # @param [String] url               git URL
      # @param [String] subpath           lesson path
      # @option opts [String] branch      branch name, defaults to master
      # @raise [GitCloneError]      if the clone operation failed.
      # @raise [InvalidLessonError] if the given lesson is invalid.
      # @return [Lesson]            lesson
      def clone_from(url, subpath, opts={})
        # TODO: lock
        path = File.join source_path, subpath
        repo = Git.clone_from url, path, DEFAULTS.merge(opts)
        Lamp.logger.info { 'Successfully cloned from %s to %s' % [url, path] }
        begin Lesson.new repo
        rescue => e # clean up in case of errors
          Lamp.logger.error(e.message)
          FileUtils.remove_entry_secure repo.working_dir
          raise e
        end
      end

      private

      # Ensures that the source and compiled directories exist.
      # @return [Void]
      def prepare_directories
        FileUtils.mkdir_p source_path
        FileUtils.mkdir_p compiled_path
      end

    end

    prepare_directories
    attr_reader :repo

    # Creates a new lesson from the given repo.
    # @param [Grit::Repo] repo          git repository
    # @raise [InvalidLessonError] if the repository doesn't contain a valid
    #   +manifest.json+ and a valid +index.md+.
    # @todo TODO actually parse manifest.json
    # @todo TODO move {INDEX_FILE} to Aladdin
    def initialize(repo)
      unless File.exist? File.expand_path(Aladdin::Config::FILE, repo.working_dir)
        raise MissingManifestError.new repo.working_dir
      end
      unless File.exist? File.expand_path(INDEX_FILE, repo.working_dir)
        raise MissingIndexError.new repo.working_dir
      end
      @repo = repo
    end

    # Removes the source and compiled directories of this lesson, if they
    # exist.
    def remove
      # TODO
      FileUtils.remove_entry_secure repo.working_dir
      Lamp.logger.info { 'Removed directory at %s' % repo.working_dir }
    end
    alias :rm :remove

  end

end
