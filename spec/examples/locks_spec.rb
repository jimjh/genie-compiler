# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'timeout'
require 'lamp/lesson'

describe Lamp::Lesson do

  describe '::obtain_lock and ::release_lock' do

    include_context 'lesson repo'

    TIMEOUT = 0.6
    NAME    = SecureRandom.uuid

    alias :original_timeout :timeout
    def timeout; original_timeout TIMEOUT; end

    context 'given a fake repo' do

      context 'and a locked, but non-existent lesson' do

        before(:each) { @lock = Lamp::Lesson.send :obtain_lock, NAME }
        after(:each)  { Lamp::Lesson.send :release_lock, @lock }

        it 'is unable to clone' do
          expect { Lamp::Lesson.clone_from url, NAME }.to timeout
        end

        it 'is unable to create' do
          expect { Lamp::Lesson.create url, NAME }.to timeout
        end

        it 'is able to create a different lesson' do
          expect { Lamp::Lesson.create url, 'test-1' }.to_not timeout
        end

      end

      context 'and a locked, but existing lesson' do

        before :each do
          Lamp::Lesson.clone_from url, NAME
          @lock = Lamp::Lesson.send :obtain_lock, NAME
        end

        after :each do
          Lamp::Lesson.send :release_lock, @lock
          Lamp::Lesson.rm NAME
        end

        it 'is unable to remove' do
          expect { Lamp::Lesson.rm NAME }.to timeout
        end

        it 'is unable to compile' do
          expect { Lamp::Lesson.compile NAME }.to timeout
        end

      end

      context 'and an unlocked lesson' do

        after :each do
          begin Lamp::Lesson.rm NAME
          rescue Grit::NoSuchPathError
          end
        end

        it 'is able to clone' do
          expect { Lamp::Lesson.clone_from url, NAME }.to_not timeout
        end

        it 'is able to create' do
          expect { Lamp::Lesson.create url, NAME }.to_not timeout
        end

        it 'is able to remove' do
          Lamp::Lesson.clone_from url, NAME
          expect { Lamp::Lesson.rm NAME }.to_not timeout
        end

        it 'is able to compile' do
          Lamp::Lesson.clone_from url, NAME
          expect { Lamp::Lesson.compile NAME }.to_not timeout
        end

        it 'created a private lock directory' do
          Lamp::Lesson.clone_from url, NAME
          Lamp::Lesson.lock_path(NAME).should have_mode(Lamp::PERMISSIONS[:private_dir])
        end

        it 'created a private lock file' do
          Lamp::Lesson.clone_from url, NAME
          lock = Lamp::Lesson.lock_path(NAME) + Lamp::Lesson::LOCK_FILE
          lock.should have_mode(Lamp::PERMISSIONS[:private_file])
        end

      end

    end

    context 'two operations' do

      let(:dir) { Pathname.new Lamp::Lesson.clone_from(url, NAME).repo.working_dir }

      it 'completes one after another' do
        dir.should be_directory
        Lamp::Lesson.rm NAME
        dir.should_not be_exist
      end

    end

  end
end
