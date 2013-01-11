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
    # @return [String] path
    def directory(path, opts={})
      path = to_path path
      if path.directory?
        return path.to_s unless opts[:force]
        Actions.remove path
      elsif path.exist? then not_directory path
      end
      Lamp.logger.record :directory, path.basename
      opts.delete :force
      FileUtils.mkpath(path, opts).first
    end

    # Removes the file/directory at +path+.
    # @param [String|Pathname] path
    # @return [void]
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
    # @param [Array]    names         array of dir/file names
    # @option opts [Fixum] file_mode       UNIX permissions for files
    # @option opts [Fixum] dir_mode        UNIX permissions for directories
    # @return [Array] names
    def copy_secure(source, destination, names, opts={})
      source, destination = to_path(source), to_path(destination)
      names.each do |name|
        path = source + name
        if Actions.descends_from? source, path and path.exist?
          Actions.copy path, destination, opts
        else Lamp.logger.record :ignore, path
        end
      end
    end

    # Copies +src+ to +dest+ recursively. If the destination file/directory
    # exists, it's overwritten.
    # @param [String|Pathname] src      source file or directory
    # @param [String|Pathname] dest     destination directory
    # @option opts [Fixum] file_mode       UNIX permissions for files
    # @option opts [Fixum] dir_mode        UNIX permissions for directories
    # @return [String|Pathname] dest
    def copy(src, dest, opts={})
      src, dest = to_path(src), to_path(dest)
      not_found     src  unless src.exist?
      not_directory dest unless dest.directory?
      op = (dest + src.basename).exist? ? :overwrite : :create
      Lamp.logger.record op, src.basename
      FileUtils.cp_r src, dest, remove_destination: true
      if opts.has_key? :file_mode and opts.has_key? :dir_mode
        Actions.recursively(dest + src.basename) do |entry|
          if entry.directory? then entry.chmod opts[:dir_mode]
          elsif entry.file? then entry.chmod opts[:file_mode]
          end
        end
      end
      dest
    end

    # Invokes given block on each child recursively. Note that +Dir.glob(*/**)+
    # does not follow symlinks.
    # @param [String|Pathname] path         root
    # @return [Array] array of path's children
    def recursively(path, &block)
      Dir.glob(to_path(path) + '*/**').each(&block)
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
