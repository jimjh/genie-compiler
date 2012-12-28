# ~*~ encoding: utf-8 ~*~
require 'lamp'
require 'thor'

module Lamp

  # The lamp-cli module exposes a command-line interface using Thor.
  class Cli < Thor

    desc 'clone GIT_URL LESSON_PATH', 'Clones the git repository at GIT_URL to LESSON_PATH'
    option :branch, type: :string, default: Lesson::DEFAULTS[:branch]
    # +lamp clone+
    def clone(url, subpath)
      Lesson::clone_from url, subpath, branch: options[:branch]
    end

    desc 'compile LESSON_PATH', 'Generates compressed HTML files from the lesson source at LESSON_PATH'
    # +lamp compile+
    def compile(subpath)
      Lesson::compile subpath
    end

  end

end
