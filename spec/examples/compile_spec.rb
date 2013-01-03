# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe 'Lamp::Lesson::compile' do

  context 'given a lesson source' do

    include_context 'lesson repo'
    include_context 'file ops'

    def compile
      Lamp::Lesson.clone_from url, 'test'
      Lamp::Lesson.compile 'test'
    end

    it 'should ensure that the target directory is empty' do
      dest = empty_directory Lamp::Lesson.compiled_path + 'test'
      rand = random_file dest + Aladdin::Config::FILE
      compile
      IO.read(dest + Aladdin::Config::FILE).should_not eql rand
    end

    it 'should copy static assets to target directory' do
      empty_directory @fake_repo + 'img'
      rand = random_file @fake_repo + 'img' + 'x'
      IO.write @fake_repo + Aladdin::Config::FILE, '{"static_paths": ["img"]}'
      commit_all
      compile
      IO.read(Lamp::Lesson.compiled_path('test') + 'img' + 'x').should eql rand
    end

    it 'should not copy anything else' do
      random_file @fake_repo + 'x'
      random_file @fake_repo + 'y'
      empty_directory @fake_repo + 'z'
      random_file @fake_repo + 'z' + 'w'
      commit_all
      compile
      (Lamp::Lesson.compiled_path('test') + 'x').should_not be_exist
      (Lamp::Lesson.compiled_path('test') + 'y').should_not be_exist
      (Lamp::Lesson.compiled_path('test') + 'z').should_not be_exist
      (Lamp::Lesson.compiled_path('test') + 'z' + 'w').should_not be_exist
    end

    it 'should render all markdown sources into html' do
      rand = random_file(@fake_repo + 'x.md')  { |r| "_#{r}_" }
      commit_all
      compile
      IO.read(Lamp::Lesson.compiled_path('test') + 'x.inc').should match "<em>#{rand}</em>"
    end

  end

end

