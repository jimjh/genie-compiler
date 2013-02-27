# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'lamp/lesson'

describe Lamp::Lesson do

  describe '::remove' do

    context 'given a lesson name' do

      include_context 'lesson repo'
      let(:name) { 'test' }

      before(:each) { @lesson = Lamp::Lesson.clone_from url, name }

      context 'after compile' do

        before(:each) { @lesson.compile }

        it 'removes the source and compiled directories' do
          expect { @lesson.rm }.to_not raise_error
          Lamp::Lesson.source_path(name).should_not be_exist
          Lamp::Lesson.compiled_path(name).should_not be_exist
        end

      end

      context 'before compile' do

        it 'does not raise an error' do
          expect { @lesson.rm }.to_not raise_error
          Lamp::Lesson.source_path(name).should_not be_exist
          Lamp::Lesson.compiled_path(name).should_not be_exist
        end

      end

      it 'raises an error if the specified lesson does not exist' do
        expect { Lamp::Lesson::rm 'x' }.to raise_error
      end

      it 'does not raise an error if the specified lesson exists' do
        expect { Lamp::Lesson::rm name }.to_not raise_error
      end

      it 'raises an error if remove is given an unsafe name' do
        expect { Lamp::Lesson.rm '../jimjh/x' }.to raise_error Lamp::Lesson::NameError
      end

    end

  end

end
