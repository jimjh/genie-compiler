# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'lamp/cli'

describe Lamp::Cli do

  subject { Lamp::Cli }

  context 'thor task' do
    subject { Lamp::Cli.all_tasks['server'] }
    it { should_not be_nil }
    its(:options) { should have_key(:port) }
    its(:options) { should satisfy { |o| o[:port].type == :numeric } }
  end

  describe '::server' do

    it 'invokes Lamp::server' do
      Lamp.expects(:server).with(has_entry('port', 1234)).returns(nil)
      Lamp::Cli.start(%w[server --port 1234])
    end

  end

  describe '::client' do

    it 'invokes Lamp::client' do
      Lamp.expects(:client).with(anything, kind_of(Array), has_entry('port', 5555)).returns(nil)
      Lamp::Cli.start(%w[client --port 5555])
    end

  end

end
