# ~*~ encoding: utf-8 ~*~
module Lamp

  module Actions

    # Actions for manipulating the file system.
    module FileActions

      # Errors related to file actions.
      class FileError < Lamp::Error; end

      # Attempts to open file for reading at +path+.
      # @param [String|Pathname] path        path to file
      # @return [void]
      def check_file(path)
        path = Pathname.new path unless path.is_a? Pathname
        not_found    path unless path.exist?
        not_readable path unless path.readable?
        Lamp.logger.record :read, path.basename
      end

      # Writes a file.
      # @param [String|Pathname] path       path to file
      # @param [String] contents            contents to be written
      # @param [String] mode                e.g. wb+
      # @return [void]
      def write_file(path, contents, mode)
        path     = Pathname.new path unless path.is_a? Pathname
        skip, op = false, :create
        if path.exist?
          if IO.read(path) == contents
            skip, op = true, :identical
          else op = :overwrite
          end
        end
        Lamp.logger.record op, path.basename
        open(path, mode) { |file| file.write contents } unless skip
      end

      # Raises an FileError.
      # @param [String|Pathname] path        path to file
      # @return [void]
      def not_found(path)
        raise FileError, 'Unable to locate file at %s' % path, caller
      end

      # Raises an FileError.
      # @param [String|Pathname] path        path to file
      # @return [void]
      def not_readable(path)
        raise FileError, 'Unable to read file at %s' % path, caller
      end

    end

    include FileActions

  end

end