# ~*~ encoding: utf-8 ~*~
module Lamp

  module Git

    # This is raised if a git operation failed.
    class GitError < Error; end

    # This is raised if a +git clone+ operation failed.
    class GitCloneError < GitError; end

  end
end
