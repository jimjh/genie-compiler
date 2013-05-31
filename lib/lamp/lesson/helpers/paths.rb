require 'pathname'
require 'active_support/concern'
module Lamp
  module Helpers
    module Paths
      extend ActiveSupport::Concern

      included do
        private
        # add path readers for each path type
        path_reader :source, :compiled, :solution, :lock
      end

      # @return [Hash] hash containing the compiled path and solution path.
      def public_paths
        { compiled_path: compiled_path,
          solution_path: solution_path }
      end

      # @return [String] absolute path to the given item in the repository.
      def in_repo(subpath)
        File.expand_path subpath, repo.working_dir
      end

      module ClassMethods

        # Dynamically defines getter methods for path types. Each getter method
        # takes an argument that specifies the name of the lesson (or subpath)
        # and returns a Pathname.
        %w[source compiled solution lock].each do |type|
          define_method :"#{type}_path" do |*args|
            subpath = args.first || '.'
            Pathname.new(Lamp.root) + type + subpath
          end
        end

        # Dynamically defines getter methods for path types. Each getter method
        # returns a Pathname.
        # @param  [Array] types           array of path types
        # @return [void]
        def path_reader(*types)
          types.each do |type|
            m = :"#{type}_path"
            define_method(m) { Lesson.public_send m, self.name }
          end
        end

      end

    end
  end
end
