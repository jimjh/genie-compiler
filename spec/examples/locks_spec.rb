# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'timeout'

describe Lamp::Lesson do

  describe '::obtain_lock and ::release_lock' do

    include_context 'lesson repo'
    TIMEOUT = 0.6

    alias :original_timeout :timeout
    def timeout; original_timeout TIMEOUT; end

    context 'given a fake repo' do

      context 'and a locked, but non-existent lesson' do

        before(:each) { @lock = Lamp::Lesson.send :obtain_lock, 'test' }
        after(:each)  { Lamp::Lesson.send :release_lock, @lock }

        it 'is unable to clone' do
          expect { Lamp::Lesson.clone_from url, 'test' }.to timeout
        end

        it 'is unable to create' do
          expect { Lamp::Lesson.create url, 'test' }.to timeout
        end

        it 'is able to create a different lesson' do
          expect { Lamp::Lesson.create url, 'test-1' }.to_not timeout
        end

      end

      context 'and a locked, but existing lesson' do

        before :each do
          Lamp::Lesson.clone_from url, 'test'
          @lock = Lamp::Lesson.send :obtain_lock, 'test'
        end

        after :each do
          Lamp::Lesson.send :release_lock, @lock
          Lamp::Lesson.rm 'test'
        end

        it 'is unable to remove' do
          expect { Lamp::Lesson.rm 'test' }.to timeout
        end

        it 'is unable to compile' do
          expect { Lamp::Lesson.compile 'test' }.to timeout
        end

      end

      context 'and an unlocked lesson' do

        after :each do
          begin Lamp::Lesson.rm 'test'
          rescue Grit::NoSuchPathError
          end
        end

        it 'is able to clone' do
          expect { Lamp::Lesson.clone_from url, 'test' }.to_not timeout
        end

        it 'is able to create' do
          expect { Lamp::Lesson.create url, 'test' }.to_not timeout
        end

        it 'is able to remove' do
          Lamp::Lesson.clone_from url, 'test'
          expect { Lamp::Lesson.rm 'test' }.to_not timeout
        end

        it 'is able to compile' do
          Lamp::Lesson.clone_from url, 'test'
          expect { Lamp::Lesson.compile 'test' }.to_not timeout
        end

      end

    end

    context 'two operations' do

      let(:dir) { Pathname.new Lamp::Lesson.clone_from(url, 'test').repo.working_dir }

      it 'completes one after another' do
        dir.should be_directory
        Lamp::Lesson.rm 'test'
        dir.should_not be_exist
      end

    end

  end
end
