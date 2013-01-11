# ~*~ encoding: utf-8 ~*~
require 'spec_helper.rb'

describe Lamp::Lesson do

  describe '::create' do

    context 'given a fake repository' do

      include_context 'lesson repo'

      NAME = 'test'

      it 'clones, compiles, and cleans' do
        lesson = Lamp::Lesson.create url, NAME
        Lamp::Lesson.source_path(NAME).should_not be_exist
        Lamp::Lesson.compiled_path(NAME).should be_exist
      end

    end

    it 'raises an error if create is given an unsafe name' do
      expect { Lamp::Lesson.create 'x', '../jimjh/x' }.to raise_error Lamp::Lesson::NameError
    end

  end

end
