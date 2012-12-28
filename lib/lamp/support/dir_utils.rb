# ~*~ encoding: utf-8 ~*~
require 'active_support/core_ext/string'

# Additional utility functions for FileUtils.
module Lamp
  module Support

    module DirUtils
      extend self

      # Ensures that the given path is an empty directory.
      # @param [Pathname] dir         path to directory
      def ensure_empty(dir)
        if dir.exist?
          Lamp.logger.warn { 'Overwriting directory at %s' % dir }
          FileUtils.remove_entry_secure dir
        end
        FileUtils.mkdir_p dir
      end

      # Copies +files+ from +source+ to +destination+. Ensures that the files
      # to be copied are really children of +source+.
      # @param [Pathname] source        source directory
      # @param [Pathname] destination   destination directory
      # @param [Array]    files         array of file names
      def copy_secure(source, destination, files)
        files.each do |file|
          path = (source + file).cleanpath.to_s
          if path.starts_with?(source.to_s)
            FileUtils.cp_r path, destination, verbose: true
          else Lamp.logger.warn { 'Ignoring suspicious path %s' % path }
          end
        end
      end

    end

  end
end
