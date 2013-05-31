# ~*~ encoding: utf-8 ~*~
require 'spec_helper.rb'
require 'lamp/lesson'

describe Lamp::Lesson do

  describe '::create' do

    context 'given a fake repository' do

      include_context 'lesson repo'
      let(:name) { SecureRandom.uuid }
      subject { Lamp::Lesson.create url, name }

      its(:source_path) { should_not be_exist }
      its(:compiled_path) { should be_exist }

    end

    context 'given an unsafe name' do
      let(:name) { '../jimjh/x' }
      it 'raises an error' do
        expect { Lamp::Lesson.create 'x', name}.to raise_error \
          Lamp::Lesson::NameError
      end
    end

  end

end
