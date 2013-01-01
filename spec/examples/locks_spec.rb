# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'timeout'

describe 'Lamp::Lesson::obtain_lock and Lamp::Lesson::release_lock' do

  TIMEOUT = 0.5

  context 'given a fake repo' do

    include_context 'lesson repo'

    it 'should not be able to clone without lock' do
      lock = Lamp::Lesson.send :obtain_lock, 'test'
      expect { Lamp::Lesson.clone_from url, 'test' }.to timeout(TIMEOUT)
      Lamp::Lesson.send :release_lock, lock
      expect { Lamp::Lesson.clone_from url, 'test' }.to_not timeout(TIMEOUT)
    end

    it 'should not be able to create without lock' do
      lock = Lamp::Lesson.send :obtain_lock, 'test'
      expect { Lamp::Lesson.create url, 'test' }.to timeout(TIMEOUT)
      Lamp::Lesson.send :release_lock, lock
      expect { Lamp::Lesson.create url, 'test' }.to_not timeout(TIMEOUT)
    end

    it 'should be able to remove without lock' do
      Lamp::Lesson.clone_from url, 'test'
      lock = Lamp::Lesson.send :obtain_lock, 'test'
      expect { Lamp::Lesson.remove 'test' }.to timeout(TIMEOUT)
      Lamp::Lesson.send :release_lock, lock
      expect { Lamp::Lesson.remove 'test' }.to_not timeout(TIMEOUT)
    end

    it 'should not be able to compile without lock' do
      Lamp::Lesson.clone_from url, 'test'
      lock = Lamp::Lesson.send :obtain_lock, 'test'
      expect { Lamp::Lesson.compile 'test' }.to timeout(TIMEOUT)
      Lamp::Lesson.send :release_lock, lock
      expect { Lamp::Lesson.compile 'test' }.to_not timeout(TIMEOUT)
    end

    it 'should be able to lock different lessons' do
      Lamp::Lesson.clone_from url, 'test'
      lock = Lamp::Lesson.send :obtain_lock, 'x'
      expect { Lamp::Lesson.compile 'test' }.to_not timeout(TIMEOUT)
      Lamp::Lesson.send :release_lock, lock
    end

  end

  context 'two operations' do

    include_context 'lesson repo'

    it 'should complete one after another' do
      lesson = Lamp::Lesson.clone_from url, 'test'
      dir    = lesson.repo.working_dir
      Pathname.new(dir).should be_exist
      Lamp::Lesson.remove 'test'
      Pathname.new(dir).should_not be_exist
    end

  end

end
