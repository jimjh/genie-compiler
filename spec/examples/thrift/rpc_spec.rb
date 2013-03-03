# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'shared/validation_matcher'

require 'lamp/thrift/gen'
require 'lamp/thrift/handler'

describe Lamp::RPC::Handler, :focus do

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
    let(:args) do
      ['git@github.com/jimjh/floating-point-tutorial.git',
       'jimjh/floating-point',
       'http://localhost/callback', {}]
    end
    it { should validate_presence_of(0, 'git_url').on(:create).with(args)     }
    it { should validate_presence_of(1, 'lesson_path').on(:create).with(args) }
    it { should validate_presence_of(2, 'callback').on(:create).with(args)    }
    it { should validate_uri_format_of(2, 'callback').on(:create).with(args) }
  end

  describe '#remove' do
    let(:args) { ['jimjh/floating-point', 'http://localhost/callback' ] }
    it { should validate_presence_of(0, 'lesson_path').on(:remove).with(args) }
    it { should validate_presence_of(1, 'callback').on(:remove).with(args)    }
    it { should validate_uri_format_of(1, 'callback').on(:remove).with(args) }
  end

end
