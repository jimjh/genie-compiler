# ~*~ encoding: utf-8 ~*~
require 'open3'
require 'lamp/actions'

module Lamp

  module Git

    extend self

    # Default set of flags to pass to +git clone+
    CLONE_OPTS = { branch: 'master', depth: 100 }.freeze

    # +git clone+ command
    CLONE_COMMAND = %w[git clone --quiet].freeze

    # Clones the git repository at the given URL to +path+. If the directory
    # at the given path exists, it's emptied.
    # @param        [String]    url         git URL
    # @param        [Pathaname] path        path of target directory
    # @option opts  [String]    branch      branch name
    # @return [Grit::Repo] repository
    # @raise  [GitCloneError] if the clone failed
    def clone_from(url, path, opts={})
      opts = CLONE_OPTS.dup.deep_merge(opts)
      Actions.directory path, force: true, mode: PERMISSIONS[:private_dir]
      cmd = CLONE_COMMAND + opts.map { |k, v| "--#{k}=#{v}" }
      Open3.popen3(*cmd, url, path.to_s) do |i, o, e, t|
        raise GitCloneError, e.read, caller unless t.value.success?
      end
      Grit::Repo.new path
    end

  end

end
