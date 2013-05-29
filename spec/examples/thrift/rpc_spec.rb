# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'shared/validation_matcher'

require 'lamp/rpc/gen'
require 'lamp/rpc/handler'

describe Lamp::RPC::Handler do

  describe '#ping' do
    its(:ping) { should eq 'pong!' }
  end

  describe '#info' do

    its(:info) { should respond_to :uptime }
    its(:info) { should respond_to :threads }

    it 'reports the uptime' do
      subject.info.uptime.should >= 0
    end

    it 'reports the number of threads' do
      subject.info.threads.should have_key 'total'
      subject.info.threads.should have_key 'running'
    end

  end

  describe '#create' do

    include_context 'lesson repo'

    let(:callback) { 'http://localhost:1234/callback' }
    let(:args) { [url, 'jimjh/floating-point', callback, {}] }

    it { should validate_presence_of(0, 'git_url').on(:create).with(args)     }
    it { should validate_presence_of(1, 'lesson_path').on(:create).with(args) }
    it { should validate_presence_of(2, 'callback').on(:create).with(args)    }
    it { should validate_uri_format_of(2, 'callback').on(:create).with(args)  }

    it 'fires the callback with status=200 on success' do
      Faraday.expects(:post).once
        .with(callback, has_entry(:status, 200) & has_key(:payload))
      subject.create(*args).join
    end

    it 'fires the callback with status=502 on failure' do
      Faraday.expects(:post).once
        .with(callback, has_entry(:status, 502) & has_key(:message))
      Lamp::Lesson.expects(:create).raises(Lamp::Error)
      subject.create(*args).join
    end

    it 'fires the callback with status=422 on InvalidLessonError' do
      Faraday.expects(:post).once
        .with(callback, has_entry(:status, 422) & has_key(:errors))
      Lamp::Lesson.expects(:create).raises(Lamp::Lesson::InvalidLessonError, [])
      subject.create(*args).join
    end

  end

  describe '#remove' do

    let(:name)     { 'jimjh/floating-point' }
    let(:callback) { 'http://localhost:1234/callback' }
    let(:args)     { [ name, callback ] }

    it { should validate_presence_of(0, 'lesson_path').on(:remove).with(args) }
    it { should validate_presence_of(1, 'callback').on(:remove).with(args)    }
    it { should validate_uri_format_of(1, 'callback').on(:remove).with(args) }

    context 'given an existing lesson' do

      include_context 'lesson repo'
      before(:each) { Lamp::Lesson.clone_from url, name }

      it 'fires the callback with status=200 on success' do
        Faraday.expects(:post).once
          .with(callback, has_entry(:status, 200) & has_key(:payload))
        subject.remove(*args).join
      end

      it 'fires the callback with status=502 on failure' do
        Lamp::Lesson.expects(:rm).raises(Lamp::Error)
        Faraday.expects(:post).once
          .with(callback, has_entry(:status, 502) & has_key(:message))
        subject.remove(*args).join
      end

    end

  end

end
