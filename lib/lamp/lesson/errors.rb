# ~*~ encoding: utf-8 ~*~
module Lamp

  class Lesson

    # Raised if the given lesson repository does not contain the required
    # files.
    class InvalidLessonError < StandardError; end

    # Raised if repository already contains the dirty branch.
    class DirtyBranchError < InvalidLessonError; end

    # Raised if the repository doesn't contain index.md
    class MissingIndexError < InvalidLessonError; end

    # Raised if the repository doesn't contain manifest.json
    class MissingManifestError < InvalidLessonError; end

    # Raised if the worker is unable to obtain a lock on the lesson.
    class LockError < StandardError; end

    # Raised if the given lesson name is invalid.
    class NameError < StandardError; end

  end

end
