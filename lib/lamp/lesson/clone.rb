# ~*~ encoding: utf-8 ~*~
module Lamp

  class Lesson

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
    def self.clone_from(url, name, opts={})
      # TODO: lock
      path = source_path name
      repo = Git.clone_from url, path, DEFAULTS.merge(opts)
      Lamp.logger.info { 'Successfully cloned from %s to %s' % [url, path] }
      begin Lesson.new repo, name
      rescue => e # clean up in case of errors
        Lamp.logger.error(e.message)
        FileUtils.remove_entry_secure repo.working_dir
        raise e
      end
    end

  end

end
