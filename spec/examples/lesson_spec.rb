# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'lamp/lesson'

describe Lamp::Lesson do

  context 'given a cloned lesson' do

    include_context 'lesson repo'
    let(:name) { 'test_lesson' }
    let(:lesson) { clone_lesson name }
    subject { lesson }

    its(:solution_path) { should eq Pathname.new(Lamp.root)+'solution'+name }
    its(:compiled_path) { should eq Pathname.new(Lamp.root)+'compiled'+name }
    its(:source_path) { should eq Pathname.new(Lamp.root)+'source'+name }
    its(:lock_path) { should eq Pathname.new(Lamp.root)+'lock'+name }

    its(:public_paths) { should have_key :compiled_path }
    its(:public_paths) { should have_key :solution_path }

    its(:title) { should eq Lamp::DEFAULT_MANIFEST[:title] }
    its(:description) { should eq Lamp::DEFAULT_MANIFEST[:description] }
    its(:static_paths) { should eq Lamp::DEFAULT_MANIFEST[:static_paths] }

    describe '#in_repo' do
      it 'returns absolute paths to files in the repository' do
        lesson.in_repo('x').should eq File.join(lesson.source_path, 'x')
      end
    end

  end

  # method already invoked by global context
  describe '::prepare_directories' do
    subject { Lamp::Lesson }
    its(:compiled_path) { should have_mode_of :public_dir }
    its(:compiled_path) { should eq Pathname.new(Lamp.root)+'compiled' }
    its(:lock_path) { should have_mode_of :private_dir }
    its(:lock_path) { should eq Pathname.new(Lamp.root)+'lock' }
    its(:source_path) { should have_mode_of :private_dir }
    its(:source_path) { should eq Pathname.new(Lamp.root)+'source' }
    its(:solution_path) { should have_mode_of :shared_dir }
    its(:solution_path) { should eq Pathname.new(Lamp.root)+'solution' }
  end

end
