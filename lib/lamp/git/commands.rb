# ~*~ encoding: utf-8 ~*~
require 'open3'

module Lamp

  module Git
    extend self

    # Default set of flags to pass to +git clone+.
    CLONE_FLAGS = %w(--quiet --depth=100)

    # Clones the git repository at the given URL to +path+. If the directory
    # at the given path exists, it's emptied.
    # @param [String] url           git URL
    # @param [String] path          path of target directory
    # @option opts [String] branch  branch name
    # @return [Grit::Repo] repository
    def clone_from(url, path, opts)
      ensure_empty path
      flags = CLONE_FLAGS + ['--branch=' + opts[:branch]]
      Open3.popen3 'git', 'clone', *flags,
        url, path do |i, o, e, t|
          raise GitCloneError.new e.read unless t.value.success?
        end
      Grit::Repo.new path
    end

    private

    # Ensures that the given path is an empty directory.
    # @param [String] dir         path to directory
    def ensure_empty(dir)
      return unless File.exist? dir
      FileUtils.remove_entry_secure dir
      FileUtils.mkdir_p dir
    end

  end

end
