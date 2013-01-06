# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe 'Lamp::Lesson::clone_from' do

  context 'given a fake repository' do

    include_context 'lesson repo'
    include_context 'file ops'
    let(:master) { Grit::Repo.new(@fake_repo).head.commit.id }

    it 'should default to the master branch' do
      lesson = Lamp::Lesson.clone_from url, 'test'
      lesson.repo.head.commit.id.should eq master
      lesson.rm
    end

    it 'should use the specified branch' do
      silence @fake_repo, <<-eos
        git co -b x
        git ci --allow-empty -am 'branch'
      eos
      commit = Grit::Repo.new(@fake_repo).head.commit.id
      lesson = Lamp::Lesson.clone_from url, 'test', branch: 'x'
      lesson.repo.head.commit.id.should eq commit
      lesson.rm
    end

    it 'should raise a GitCloneError if the repository does not exist' do
      expect do
        Lamp::Lesson.clone_from 'random/dot.git', 'test'
      end.to raise_error Lamp::Git::GitCloneError
    end

    it 'should raise a MissingIndexError if the index is missing.' do
      (@fake_repo + Lamp::Lesson::INDEX_FILE).unlink
      commit_all
      expect do
        Lamp::Lesson.clone_from url, 'test'
      end.to raise_error Lamp::Actions::FileActions::FileError
    end

    it 'should raise a MissingManifestError if the manifest is missing.' do
      (@fake_repo + Aladdin::Config::FILE).unlink
      commit_all
      expect do
        Lamp::Lesson.clone_from url, 'test'
      end.to raise_error Lamp::Actions::FileActions::FileError
    end

    it 'should overwrite any existing lessons.' do
      dir = empty_directory Lamp::Lesson.source_path + 'test'
      random_file dir + 'x'
      Lamp::Lesson.clone_from url, 'test'
      dir.should be_directory
      (dir + Aladdin::Config::FILE).should be_file
      (dir + 'x').should_not be_file
    end

  end

end
