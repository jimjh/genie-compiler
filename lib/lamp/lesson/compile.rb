# ~*~ encoding: utf-8 ~*~
require 'aladdin/render'

module Lamp

  class Lesson

    # Glob used by Pathname to look for markdown sources.
    GLOB        = '*.{md,markdown,mkd}'

    # File extension for render output.
    EXT       = '.inc'

    class << self

      # Generates compressed HTML files from the specified lesson.
      # @param [String] name           lesson path, aka name
      # @return [String] path to compiled lesson
      def compile(name)
        # TODO: lock
        path = source_path name
        lesson = new Grit::Repo.new(path), name
        lesson.compile
      end

    end

    # Compiles the lesson into HTML files, then copies these, the manifest, and
    # the static files to +{ROOT}/compiled/{LESSON_PATH}+. Be wary of directory
    # attacks in +@manifest[:static_paths]+.
    # @return [Pathname] path to compiled lesson
    def compile
      Support::DirUtils.ensure_empty compiled_path
      sources = [Aladdin::Config::FILE] + @manifest[:static_paths]
      Support::DirUtils.copy_secure source_path, compiled_path, sources
      Pathname.glob(source_path + GLOB).each { |path| render path, compiled_path }
      compiled_path
    end

    private

    # Renders the given markdown file as HTML and writes its contents out to
    # +destination+.
    # @param [Pathname] source            path to markdown source
    # @param [Pathname] destination       path to output directory
    # @return [Fixnum] number of bytes written
    def render(source, destination)
      html = @markdown.render File.read source.to_s
      IO.write(destination + source.basename.sub_ext(EXT), html)
    end

  end

end
