# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe 'remove' do

  context 'given a lesson name' do

    include_context 'lesson repo'

    before(:each) do
      @lesson = Lamp::Lesson.clone_from url, 'test'
    end

    it 'should remove the source and compiled directories' do
      @lesson.compile
      Lamp::Lesson.source_path('test').should be_exist
      Lamp::Lesson.compiled_path('test').should be_exist
      @lesson.rm
      Lamp::Lesson.source_path('test').should_not be_exist
      Lamp::Lesson.compiled_path('test').should_not be_exist
    end

    it 'should not raise an error if the compiled directory does not exist' do
      expect { @lesson.rm }.to_not raise_error
    end

  end

end

