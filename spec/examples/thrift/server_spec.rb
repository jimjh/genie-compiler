# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'lamp/rpc/server'

describe Lamp do

  describe '::server' do

    it 'rescues from Interrupt' do
      Lamp::RPC::Server.any_instance.expects(:serve).raises(Interrupt)
      expect { Lamp.server }.to_not raise_exception
      output.should match(/Extinguished\./)
    end

  end

end

describe Lamp::RPC::Server do

  describe '#initialize' do

    let(:rand_port) { Random.rand 1000 }

    it 'sets the port number' do
      Lamp::RPC::Server.new('port' => rand_port).port.should be(rand_port)
    end

    it 'sets the port number to default value' do
      Lamp::RPC::Server.new.port.should be_zero
    end

  end

  describe '#serve' do

    let(:server) { Lamp::RPC::Server.new }

    context 'running server' do

      subject        { server }
      before(:each)  { server.serve }
      after(:each)   { server.thread.exit }

      its(:thread) { should be_alive }
      its(:thread) { should be_kind_of(Thread) }

      it 'logs the port number' do
        output.should match(/#{server.port}/)
      end

      its(:port) { should be(server.socket.handle.addr[1]) }

    end

  end

end
