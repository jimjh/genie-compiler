# ~*~ encoding: utf-8 ~*~
module Lamp
  class Lesson
    class << self

      # Clones the git repository at the given URL to
      # +{ROOT}/source/{NAME}+. The +name+ will be used as the lesson's
      # name.
      #
      # @param [String] url               git URL
      # @param [String] name              lesson path, aka name
      # @option opts [String] branch      branch name, defaults to master
      # @raise [GitCloneError]            if the clone operation failed.
      # @raise [InvalidLessonError]       if the given lesson is invalid.
      # @return [Lesson]                  lesson
      def clone_from(url, name, opts={})
        lock = obtain_lock name
        clone_from! url, name, opts
      ensure
        release_lock lock unless lock.nil?
      end

      private

      # Helper method for {#clone_from} that does not obtain locks. Extracted
      # so that it can be reused for {#create}
      def clone_from!(url, name, opts={})
        path = source_path name
        repo = Git.clone_from url, path, DEFAULTS.merge(opts)
        Lamp.logger.info { 'Successfully cloned from %s to %s' % [url, path] }
        init_or_delete repo, name
      end

      def init_or_delete(repo, name)
        Lesson.new repo, name
      rescue => e # clean up in case of errors
        Lamp.logger.error(e.message)
        source_path(name).rmtree
        raise e
      end

    end
  end
end
