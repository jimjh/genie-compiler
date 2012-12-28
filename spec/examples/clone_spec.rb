# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'securerandom'

describe 'clone' do

  context 'given a fake repository' do

    before(:all) { Lamp.settings.load! root: Dir.mktmpdir }
    after(:all)  { FileUtils.remove_entry_secure Lamp.settings.root }

    before(:each) do
      @fake_repo = Dir.mktmpdir
      Dir.chdir @fake_repo do
        system <<-eos
          (
            git init
            echo {} > manifest.json && git add manifest.json
            touch index.md && git add index.md
            git ci -m 'first commit'
          ) &> /dev/null
        eos
      end
      @master = Grit::Repo.new(@fake_repo).head.commit.id
    end

    let(:url) { File.join(@fake_repo, '.git') }

    after(:each) do
      FileUtils.remove_entry_secure @fake_repo
    end

    it 'should default to the master branch' do
      lesson = Lamp::Lesson.clone_from url, 'test'
      lesson.repo.head.commit.id.should eq @master
      lesson.rm
    end

    it 'should use the specified branch' do
      Dir.chdir @fake_repo do
        system <<-eos
          (
            git co -b x
            git ci --allow-empty -am 'branch'
          ) &> /dev/null
        eos
      end
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
      FileUtils.rm File.join(@fake_repo, Lamp::Lesson::INDEX_FILE)
      Dir.chdir @fake_repo do
        system <<-eos
          (git ci -am 'removed index') &> /dev/null
        eos
      end
      expect do
        Lamp::Lesson.clone_from url, 'test'
      end.to raise_error Lamp::Lesson::MissingIndexError
    end

    it 'should raise a MissingManifestError if the manifest is missing.' do
      FileUtils.rm File.join(@fake_repo, Aladdin::Config::FILE)
      Dir.chdir @fake_repo do
        system <<-eos
          (git ci -am 'removed manifest') &> /dev/null
        eos
      end
      expect do
        Lamp::Lesson.clone_from url, 'test'
      end.to raise_error Lamp::Lesson::MissingManifestError
    end

    it 'should overwrite any existing lessons.' do
      dir = File.join(Lamp::Lesson.source_path, 'test')
      rand = SecureRandom.uuid
      FileUtils.mkdir_p dir
      IO.write File.join(dir, 'x'), rand
      Lamp::Lesson.clone_from url, 'test'
      File.directory?(dir).should be_true
      File.exist?(File.join(dir, Aladdin::Config::FILE)).should be_true
      File.exist?(File.join(dir, 'x')).should be_false
    end

  end

end

