# ~*~ encoding: utf-8 ~*~
require 'lamp/lesson/errors'
require 'lamp/git'
require 'aladdin/config'

module Lamp

  # A lesson begins as a git repository.
  class Lesson

    # FIXME
    ROOT = '/tmp'

    # Name of branch where we do our work. Should be sufficiently unique.
    DIRTY_BRANCH = '@@genie@@'

    # Name of index file.
    INDEX_FILE = 'index.md'

    # Default options for public interface
    DEFAULTS = {
      branch:       'master',
    }

    class << self

      # Clones the git repository at the given URL to +{ROOT}/{user}+.
      # @param [String] user              some unique user ID
      # @param [String] URL               git URL
      # @option opts [String] branch      branch name, defaults to master
      # @raise [GitCloneError]      if the clone operation failed.
      # @raise [InvalidLessonError] if the given lesson is invalid.
      # @return [Lesson]            lesson
      def clone(user, url, opts={})
        # TODO: lock
        opts, path = DEFAULTS.merge(opts), File.join(ROOT, user)
        FileUtils.mkdir_p path
        repo = Git.clone url, path, opts
        begin
          ensure_pristine repo
          lesson = Lesson.new repo
          lesson.branch DIRTY_BRANCH
          lesson.prune!
          lesson
        rescue => e
          FileUtils.remove_entry_secure repo.working_dir
          raise e
        end
      end

      # Ensures that
      # - the repository does not have a @@genie@@ branch, and
      # - the directory contains +index.md+
      # @param [Grit::Repo] repo              git repository
      # @raise [InvalidLessonError] if any of the assertions fail
      def ensure_pristine(repo)
        raise DirtyBranchError.new if repo.branches.any? { |b| b.name == DIRTY_BRANCH }
        raise MissingIndexError.new unless File.exist? File.join(repo.working_dir, INDEX_FILE)
      end

    end

    # Creates a new lesson from the given repo.
    # @param [Grit::Repo] repo          git repository
    # @raise [InvalidLessonError] if the repository doesn't contain a valid
    #   +manifest.json+.
    def initialize(repo)
      raise MissingManifestError.new unless File.exist? File.join(repo.working_dir, Aladdin::Config::FILE)
      @repo = repo
    end

    # Creates a new branch from the current repository.
    # @param [String] name          name of new branch
    def branch(name)
      @repo.git.native :checkout, {b: true}, name
    end

    # Prunes the current repository to save storage space.
    def prune!
      @repo.git.native :prune
      @repo.git.native :gc, {aggressive: true}
    end

  end

end
