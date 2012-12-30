# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'timeout'

describe 'locks' do

  TIMEOUT = 0.5

  context 'given a fake repo' do

    include_context 'lesson repo'

    it 'should not be able to clone without lock' do
      lock = Lamp::Lesson.send :obtain_lock, 'test'
      expect do
        Timeout::timeout(TIMEOUT) { Lamp::Lesson.clone_from url, 'test' }
      end.to raise_error Timeout::Error
      Lamp::Lesson.send :release_lock, lock
      expect do
        Timeout::timeout(TIMEOUT) { Lamp::Lesson.clone_from url, 'test' }
      end.to_not raise_error
    end

    it 'should not be able to create without lock' do
      lock = Lamp::Lesson.send :obtain_lock, 'test'
      expect do
        Timeout::timeout(TIMEOUT) { Lamp::Lesson.create url, 'test' }
      end.to raise_error Timeout::Error
      Lamp::Lesson.send :release_lock, lock
      expect do
        Timeout::timeout(TIMEOUT) { Lamp::Lesson.create url, 'test' }
      end.to_not raise_error
    end

    it 'should be able to remove without lock' do
      Lamp::Lesson.clone_from url, 'test'
      lock = Lamp::Lesson.send :obtain_lock, 'test'
      expect do
        Timeout::timeout(TIMEOUT) { Lamp::Lesson.remove 'test' }
      end.to raise_error Timeout::Error
      Lamp::Lesson.send :release_lock, lock
      expect do
        Timeout::timeout(TIMEOUT) { Lamp::Lesson.remove 'test' }
      end.to_not raise_error
    end

    it 'should not be able to compile without lock' do
      Lamp::Lesson.clone_from url, 'test'
      lock = Lamp::Lesson.send :obtain_lock, 'test'
      expect do
        Timeout::timeout(TIMEOUT) { Lamp::Lesson.compile 'test' }
      end.to raise_error Timeout::Error
      Lamp::Lesson.send :release_lock, lock
      expect do
        Timeout::timeout(TIMEOUT) { Lamp::Lesson.compile 'test' }
      end.to_not raise_error
    end

    it 'should be able to lock different lessons' do
      Lamp::Lesson.clone_from url, 'test'
      lock = Lamp::Lesson.send :obtain_lock, 'x'
      expect do
        Timeout::timeout(TIMEOUT) { Lamp::Lesson.compile 'test' }
      end.to_not raise_error
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
