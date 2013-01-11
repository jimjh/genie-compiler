# ~*~ encoding: utf-8 ~*~
module Lamp
  class Lesson

    # Name of lock file.
    LOCK_FILE = 'lamp.lock'

    class << self

      private

      # Obtains a lock on the given lesson.
      # @param [String] name          lesson name or subpath
      # @return [File]  lock file
      def obtain_lock(name)
        dir = lock_path(name)
        directory dir, mode: PERMISSIONS[:private_dir]
        f = File.new dir+LOCK_FILE, File::RDWR|File::CREAT, PERMISSIONS[:private_file]
        raise LockError.new 'Unable to obtain lock.' if f.nil?
        f.flock File::LOCK_EX
        Lamp.logger.record :lock, name
        f
      end

      # Release the lock on the given lesson.
      # @param [File]   f   lock file
      # @return [Void]
      def release_lock(f)
        f.flock File::LOCK_UN
        Lamp.logger.record :release, File.basename(f)
      ensure
        f.close
      end

    end
  end
end
