# ~*~ encoding: utf-8 ~*~
require 'open3'

module Lamp

  module Git

    # Default set of flags to pass to +git clone+.
    CLONE_FLAGS = %w(--quiet --depth=100)

    # Clones the git repository at the given URL to +path+.
    # @return [Grit::Repo] repository
    def clone(url, path, opts={})
      flags = CLONE_FLAGS + ['--branch=' + opts[:branch]]
      Dir.chdir(path) do
        Open3.popen3 'git', 'clone', *flags,
          url do |i, o, e, t|
            raise GitCloneError.new e.read unless t.value.success?
          end
      end
      Grit::Repo.new File.join(path, File.basename(url, '.git'))
    end

    extend self

  end

end
