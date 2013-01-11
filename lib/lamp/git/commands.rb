# ~*~ encoding: utf-8 ~*~
require 'open3'

module Lamp

  module Git
    extend self
    extend Actions

    # Default set of flags to pass to +git clone+.
    CLONE_FLAGS = %w(--quiet --depth=100)

    # Clones the git repository at the given URL to +path+. If the directory
    # at the given path exists, it's emptied.
    # @param        [String]    url         git URL
    # @param        [Pathaname] path        path of target directory
    # @option opts  [String]    branch      branch name
    # @return [Grit::Repo] repository
    # @raise  [GitCloneError] if the clone failed
    def clone_from(url, path, opts)
      directory path, force: true, mode: PERMISSIONS[:private_dir]
      flags = CLONE_FLAGS + ['--branch=' + opts[:branch]]
      Open3.popen3 'git', 'clone', *flags,
        url, path.to_s do |i, o, e, t|
          raise GitCloneError.new e.read unless t.value.success?
        end
      Grit::Repo.new path
    end

  end

end
