# ~*~ encoding: utf-8 ~*~
module Lamp

  class Lesson

    # Removes the source and compiled directories of this lesson, if they
    # exist.
    # @param [String] name          lesson path, aka name
    # @raise [NameError]                if the given name is invalid.
    # @return [Void]
    def self.rm(name)
      ensure_safe_name name
      path = source_path name
      lock = obtain_lock name
      lesson = new Grit::Repo.new(path), name
      lesson.rm
    ensure
      release_lock lock unless lock.nil?
    end

    # Removes the source and compiled directories of this lesson, if they
    # exist.
    def rm
      [source_path, compiled_path, solution_path].each { |p| remove p }
    end

  end

end
