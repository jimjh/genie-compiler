# ~*~ encoding: utf-8 ~*~
module Lamp

  class Lesson

    # Removes the source and compiled directories of this lesson, if they
    # exist.
    def remove
      FileUtils.remove_entry_secure source_path
      Lamp.logger.info { 'Removed directory at %s' % source_path }
      FileUtils.remove_entry_secure compiled_path if compiled_path.exist?
      Lamp.logger.info { 'Removed directory at %s' % compiled_path }
    end
    alias :rm :remove

  end

end
