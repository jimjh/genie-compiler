# ~*~ encoding: utf-8 ~*~
require 'spirit'

module Lamp

  class Lesson

    # Glob used by Pathname to look for markdown sources.
    GLOB        = '*.{md,markdown,mkd}'

    # File extension for render output.
    EXT       = '.inc'

    # Generates compressed HTML files from the specified lesson.
    # @param [String] name           lesson path, aka name
    # @raise [NameError]                if the given name is invalid.
    # @return [String] path to compiled lesson
    def self.compile(name)
      ensure_safe_name name
      path = source_path name
      lock = obtain_lock name
      lesson = new Grit::Repo.new(path), name
      lesson.compile
    ensure
      release_lock lock unless lock.nil?
    end

    # Compiles the lesson into HTML files, then copies these, the manifest, and
    # the static files to +{ROOT}/compiled/{LESSON_PATH}+. Be wary of directory
    # attacks in +@manifest[:static_paths]+.
    # @return [Pathname] path to compiled lesson
    def compile
      Actions.directory compiled_path, force: true, mode: PERMISSIONS[:public_dir]
      Actions.directory solution_path, force: true
      sources = [Spirit::MANIFEST] + static_paths
      Actions.copy_secure source_path, compiled_path, sources,
        file_mode: PERMISSIONS[:public_file],
        dir_mode:  PERMISSIONS[:public_dir]
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
      html = File.open(source, 'r:utf-8') { |f| Spirit::Document.new(f).render }
      Actions.write_file destination + source.basename.sub_ext(EXT),
        html, 'w+', PERMISSIONS[:public_file]
    end

  end

end
