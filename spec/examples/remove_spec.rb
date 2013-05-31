# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'lamp/lesson'

describe Lamp::Lesson do

  describe '::remove' do

    context 'given a lesson name' do

      include_context 'lesson repo'
      let(:name)   { 'test_lesson' }
      let(:lesson) { clone_lesson name }
      subject { lesson }

      context 'after compile' do
        before(:each) { lesson.compile; lesson.rm }
        its(:source_path) { should_not be_exist }
        its(:compiled_path) { should_not be_exist }
        its(:solution_path) { should_not be_exist }
      end

      context 'before compile' do
        before(:each) { lesson.rm }
        its(:source_path) { should_not be_exist }
        its(:compiled_path) { should_not be_exist }
        its(:solution_path) { should_not be_exist }
      end

      it 'does not raises an error if the specified lesson does not exist' do
        expect { Lamp::Lesson::rm 'x' }.to_not raise_error
      end

    end

    context 'given an unsafe lesson name' do
      let(:name) { '../jimjh/x' }
      it 'raises an error' do
        expect { Lamp::Lesson.rm name }.to raise_error Lamp::Lesson::NameError
      end
    end

  end

end
