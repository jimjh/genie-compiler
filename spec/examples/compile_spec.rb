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
      empty_directory @fake_repo + 'images'
      rand = random_file @fake_repo + 'images' + 'x'
      commit_all
      compile
      IO.read(Lamp::Lesson.compiled_path('test') + 'images' + 'x').should eql rand
    end

    it 'should render all markdown sources into html' do
      rand = random_file(@fake_repo + 'x.md')  { |r| "_#{r}_" }
      commit_all
      compile
      IO.read(Lamp::Lesson.compiled_path('test') + 'x.inc').should match "<em>#{rand}</em>"
    end

  end

end

