# ~*~ encoding: utf-8 ~*~
require 'lamp/lesson/errors'
require 'lamp/git'
require 'json'
require 'pathname'
require 'aladdin/config'

module Lamp

  # A lesson begins as a git repository and ends as a set of compiled html
  # files. Note that +name+ is assumed to be safe (w.r.t. directory traversal
  # attacks.)
  class Lesson

    # Name of index file.
    INDEX_FILE = 'index.md'

    # Default options for public interface.
    DEFAULTS = {
      branch:       'master',
    }

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

      # Clones the git repository at the given URL to
      # +{ROOT}/source/{NAME}+. The +name+ will be used as the lesson's
      # name.
      #
      # @param [String] url               git URL
      # @param [String] name              lesson path, aka name
      # @option opts [String] branch      branch name, defaults to master
      # @raise [GitCloneError]            if the clone operation failed.
      # @raise [InvalidLessonError]       if the given lesson is invalid.
      # @return [Lesson]                  lesson
      def clone_from(url, name, opts={})
        # TODO: lock
        path = source_path name
        repo = Git.clone_from url, path, DEFAULTS.merge(opts)
        Lamp.logger.info { 'Successfully cloned from %s to %s' % [url, path] }
        begin Lesson.new repo, name
        rescue => e # clean up in case of errors
          Lamp.logger.error(e.message)
          FileUtils.remove_entry_secure repo.working_dir
          raise e
        end
      end

      # Generates compressed HTML files from the specified lesson.
      # @param [String] name           lesson path, aka name
      # @return [String] path to compiled lesson
      def compile(name)
        # TODO: lock
        path = source_path name
        lesson = new Grit::Repo.new(path), name
        lesson.compile
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

    # Compiles the lesson into HTML files, then copies these, the manifest, and
    # the static files to +{ROOT}/compiled/{LESSON_PATH}+. Be wary of directory
    # attacks in +@manifest[:static_paths]+.
    # @return [Pathname] path to compiled lesson
    def compile
      Support::DirUtils.ensure_empty compiled_path
      sources = [Aladdin::Config::FILE] + @manifest[:static_paths]
      Support::DirUtils.copy_secure source_path, compiled_path, sources
      compiled_path
    end

    # Removes the source and compiled directories of this lesson, if they
    # exist.
    def remove
      # TODO
      FileUtils.remove_entry_secure repo.working_dir
      Lamp.logger.info { 'Removed directory at %s' % repo.working_dir }
    end
    alias :rm :remove

    private

    def source_path
      Lesson.source_path name
    end

    def compiled_path
      Lesson.compiled_path name
    end

  end

end
