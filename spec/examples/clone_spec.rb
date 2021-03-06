# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'lamp/lesson'

describe Lamp::Lesson  do

  describe '::clone_from' do

    context 'given an unsafe name' do
      it 'raises an error' do
        expect { Lamp::Lesson.clone_from 'x', '../jimjh/x' }.to raise_error Lamp::Lesson::NameError
      end
    end

    context 'given a non-existent repository' do
      it 'raises a GitCloneError' do
        expect do
          Lamp::Lesson.clone_from "/does/not/exist/#{SecureRandom.uuid}/dot.git", 'test'
        end.to raise_error Lamp::Git::GitCloneError
      end
    end

    context 'given a fake repository' do

      include_context 'lesson repo'

      let(:master) { Grit::Repo.new(repo).get_head('master').commit.id }
      let(:commit) { Grit::Repo.new(repo).head.commit.id }

      def clone(opts={})
        @lesson = Lamp::Lesson.clone_from url, 'test', opts
      end

      after(:each) { @lesson.nil? || @lesson.rm }

      shared_examples 'clone directory permissions' do
        it 'creates a private directory' do
          dir = Pathname.new clone.repo.working_dir
          dir.should have_mode_of :private_dir
        end
      end

      it 'defaults to the master branch' do
        clone.repo.head.commit.id.should eq master
      end

      include_examples 'clone directory permissions'

      context 'with a specified branch' do

        before :each do
          silence repo, <<-eos
            git co -b x
            git ci --allow-empty -am 'branch'
          eos
        end

        it 'uses the specified branch' do
          clone(branch: 'x').repo.head.commit.id.should eq commit
        end

        include_examples 'clone directory permissions'

      end

      context 'with a missing index.md' do
        before(:each) { (repo + Spirit::INDEX).unlink; commit_all }
        it 'raises an InvalidLessonError' do
          expect { clone }.to raise_error { |e|
            e.should be_a Lamp::Lesson::InvalidLessonError
            e.errors.should eq(index: ['lesson.lamp.missing'])
          }
        end
      end

      context 'with a missing manifest' do
        before(:each) { (repo + Spirit::MANIFEST).unlink; commit_all }
        it 'raises an InvalidLessonError' do
          expect { clone }.to raise_error { |e|
            e.should be_a Lamp::Lesson::InvalidLessonError
            e.errors.should eq(manifest:  ['lesson.lamp.missing'])
          }
        end
      end

      context 'and an existing lesson at the target path' do

        let(:dir)     { empty_directory Lamp::Lesson.source_path + 'test' }
        before(:each) { random_file dir + 'x' }

        it 'overwrites any existing lessons' do
          clone.repo.head.commit.id.should eq master
          (dir + Spirit::MANIFEST).should be_file
          (dir + 'x').should_not be_file
        end

      end

    end

  end

end
