# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'timeout'
require 'lamp/lesson'

describe Lamp::Lesson, '::obtain_lock, ::release_lock' do

  include_context 'lesson repo'

  TIMEOUT = 0.6
  let(:name) { SecureRandom.uuid }

  alias :original_timeout :timeout
  def timeout; original_timeout TIMEOUT; end

  context 'given a fake repo' do

    context 'and a locked, but non-existent lesson' do

      before(:each) { @lock = Lamp::Lesson.send :obtain_lock, name }
      after(:each)  { Lamp::Lesson.send :release_lock, @lock }

      it 'is unable to clone' do
        expect { Lamp::Lesson.clone_from url, name }.to timeout
      end

      it 'is unable to create' do
        expect { Lamp::Lesson.create url, name }.to timeout
      end

      it 'is able to create a different lesson' do
        expect { Lamp::Lesson.create url, "#{name}-1" }.to_not timeout
      end

    end

    context 'and a locked, but existing lesson' do

      before :each do
        Lamp::Lesson.clone_from url, name
        @lock = Lamp::Lesson.send :obtain_lock, name
      end

      after :each do
        Lamp::Lesson.send :release_lock, @lock
        Lamp::Lesson.rm name
      end

      it 'is unable to remove' do
        expect { Lamp::Lesson.rm name }.to timeout
      end

      it 'is unable to compile' do
        expect { Lamp::Lesson.compile name }.to timeout
      end

    end

    context 'and an unlocked lesson' do

      after :each do
        begin Lamp::Lesson.rm name
        rescue Grit::NoSuchPathError
        end
      end

      it 'is able to clone' do
        expect { Lamp::Lesson.clone_from url, name }.to_not timeout
      end

      it 'is able to create' do
        expect { Lamp::Lesson.create url, name }.to_not timeout
      end

      it 'is able to remove' do
        Lamp::Lesson.clone_from url, name
        expect { Lamp::Lesson.rm name }.to_not timeout
      end

      it 'is able to compile' do
        Lamp::Lesson.clone_from url, name
        expect { Lamp::Lesson.compile name }.to_not timeout
      end

      it 'created a private lock directory' do
        Lamp::Lesson.clone_from url, name
        Lamp::Lesson.lock_path(name).should have_mode_of :private_dir
      end

      it 'created a private lock file' do
        Lamp::Lesson.clone_from url, name
        lock = Lamp::Lesson.lock_path(name) + Lamp::Lesson::LOCK_FILE
        lock.should have_mode_of :private_file
      end

    end

  end

  context 'two operations' do

    let(:dir) { Pathname.new clone_lesson(name).repo.working_dir }

    it 'completes one after another' do
      dir.should be_directory
      Lamp::Lesson.rm name
      dir.should_not be_exist
    end

  end

end
