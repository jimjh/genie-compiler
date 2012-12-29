# ~*~ encoding: utf-8 ~*~
module Lamp

  class Lesson

    # Creates a lesson from the git repository at the given URL.
    # @option opts  [String] branch     branch name, defaults to master
    # @param        [String] url        git url
    # @param        [String] name       lesson path aka name
    # @return       [Lesson] lesson
    def self.create(url, name, opts={})
      # TODO: lock
      lesson = clone_from url, name, opts
      lesson.compile
      FileUtils.remove_entry_secure source_path name
      lesson
    end

  end

end
