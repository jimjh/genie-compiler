# ~*~ encoding: utf-8 ~*~
require 'active_support/core_ext/string'

module Lamp
  module Actions

    module DirectoryActions

      # Errors related to directory actions.
      class DirectoryError < Lamp::Error; end

      # Creates a directory and all the directories necessary to reach it.
      # @param [String|Pathname] path         path of directory to create
      # @option opts [Boolean]   force        deletes existing directory, if any
      def directory(path, opts={})
        path = to_path path
        if path.directory?
          return unless opts[:force]
          Actions.remove path
        elsif path.exist? then not_directory path
        end
        Lamp.logger.record :directory, path.basename
        path.mkpath
      end

      # Removes the file/directory at +path+.
      # @param [String|Pathname] path
      def remove(path)
        path = to_path path
        if path.directory? then path.rmtree
        elsif path.exist? then path.unlink
        else return
        end
        Lamp.logger.record :remove, path.basename
      end

      # Copies +files+ from +source+ to +destination+. Ensures that the files
      # to be copied are really children of +source+.
      # @param [Pathname] source        source directory
      # @param [Pathname] destination   destination directory
      # @param [Array]    files         array of file names
      def copy_secure(source, destination, files)
        source, destination = to_path(source), to_path(destination)
        files.each do |file|
          path = source + file
          if Actions.descends_from? source, path and path.exist?
            FileUtils.cp_r path, destination
          else Lamp.logger.record :ignore, path
          end
        end
      end

      def copy(src, dest)
        src, dest = to_path(src), to_path(dest)
        op = src.exist? ? :overwrite : :create
        Lamp.logger.record op, src.basename
        FileUtils.cp_r src, dest
      end

      # @param  [Pathname] prefix     base directory
      # @param  [Pathname] path       path to check
      # @return [Boolean] true iff +path+ is a descendant  of +prefix+
      def descends_from?(prefix, path)
        basepath = prefix.to_s + File::SEPARATOR
        path.cleanpath.to_s.starts_with? basepath
      end

      # Raises a DirectoryError
      def not_directory(path)
        raise DirectoryError, '%s already exists and is not a directory' % path.basename, caller
      end

    end

  include DirectoryActions

  end
end
