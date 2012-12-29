# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'securerandom'

describe 'compile' do

  context 'given a lesson source' do

    include_context 'lesson repo'

    def compile
      Lamp::Lesson.clone_from url, 'test'
      Lamp::Lesson.compile 'test'
    end

    it 'should ensure that the target directory is empty' do
      dest = Lamp::Lesson.compiled_path + 'test'
      rand = SecureRandom.uuid
      dest.mkpath
      IO.write dest + Aladdin::Config::FILE, rand
      compile
      IO.read(dest + Aladdin::Config::FILE).should_not eql rand
    end

    it 'should copy static assets to target directory' do
      dest = Lamp::Lesson.compiled_path + 'test'
      rand = SecureRandom.uuid
      (@fake_repo + 'images').mkpath
      IO.write @fake_repo + 'images' + 'x', rand
      commit_all
      compile
      IO.read(dest + 'images' + 'x').should eql rand
    end

    it 'should render all markdown sources into html' do
      dest = Lamp::Lesson.compiled_path + 'test'
      rand = SecureRandom.uuid
      IO.write @fake_repo + 'x.md', "_#{rand}_"
      commit_all
      compile
      IO.read(dest + 'x.inc').should match "<em>#{rand}</em>"
    end

  end

end

