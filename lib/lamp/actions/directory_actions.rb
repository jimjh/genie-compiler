# ~*~ encoding: utf-8 ~*~
require 'active_support/core_ext/string'

module Lamp
  module Actions

    # Errors related to directory actions.
    class DirectoryError < Lamp::Error; end

    # Creates a directory and all the directories necessary to reach it.
    # @param [String|Pathname] path         path of directory to create
    # @option opts [Boolean]   force        deletes existing directory, if any
    # @option opts [Fixnum]    mode         directory permissions
    def directory(path, opts={})
      path = to_path path
      if path.directory?
        return unless opts[:force]
        Actions.remove path
      elsif path.exist? then not_directory path
      end
      Lamp.logger.record :directory, path.basename
      opts.delete :force
      FileUtils.mkpath path, opts
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
          Actions.copy path, destination
        else Lamp.logger.record :ignore, path
        end
      end
    end

    # Copies file(s) from +src+ to +dest+.
    # @param [String|Pathname] src      source file or directory
    # @param [String|Pathname] dest     destination directory
    # @return [void]
    def copy(src, dest)
      src, dest = to_path(src), to_path(dest)
      not_found     src  unless src.exist?
      not_directory dest unless dest.directory?
      op = (dest + src.basename).exist? ? :overwrite : :create
      Lamp.logger.record op, src.basename
      FileUtils.cp_r src, dest
    end

    # Checks if the +path+ is a descendant of +prefix+. Does not do any
    # filesystem lookups.
    # @param  [String|Pathname] prefix     base directory
    # @param  [String|Pathname] path       path to check
    # @return [Boolean] true iff +path+ is a descendant  of +prefix+
    def descends_from?(prefix, path)
      path = to_path path
      basepath = prefix.to_s + File::SEPARATOR
      path.cleanpath.to_s.starts_with? basepath
    end

    # Raises a DirectoryError
    def not_directory(path)
      raise DirectoryError, '%s already exists and is not a directory' % path.basename, caller
    end

  end
end
