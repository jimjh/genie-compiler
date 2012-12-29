# ~*~ encoding: utf-8 ~*~
require 'spec_helper.rb'

describe 'create' do

  context 'given a fake repository' do

    include_context 'lesson repo'

    it 'should clone, compile, and clean' do
      lesson = Lamp::Lesson.create url, 'test'
      Lamp::Lesson.source_path(lesson.name).should_not be_exist
      Lamp::Lesson.compiled_path(lesson.name).should be_exist
    end

  end

end

