# ~*~ encoding: utf-8 ~*~
module Lamp

  class Lesson

    # Creates a lesson from the git repository at the given URL.
    # @option opts  [String] branch     branch name, defaults to master
    # @param        [String] url        git url
    # @param        [String] name       lesson path aka name
    # @return       [Lesson] lesson
    def self.create(url, name, opts={})
      lock   = obtain_lock name
      lesson = clone_from! url, name, opts
      lesson.compile
      source_path(name).rmtree
      lesson
    ensure
      release_lock lock unless lock.nil?
    end

  end

end
