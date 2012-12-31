# ~*~ encoding: utf-8 ~*~
module Lamp

  class Lesson

    # Removes the source and compiled directories of this lesson, if they
    # exist.
    # @param [String] name          lesson path, aka name
    # @raise [NameError]                if the given name is invalid.
    # @return [Void]
    def self.remove(name)
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
    def remove
      [source_path, compiled_path, solution_path].each { |p| unlink p }
    end
    alias :rm :remove

    private

    def unlink(path)
      FileUtils.remove_entry_secure path if path.exist?
      Lamp.logger.info { 'Removed directory at %s' % path }
    end

  end

end
