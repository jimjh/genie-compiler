# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'securerandom'
require 'lamp/rpc/client'

describe Lamp do

  describe '::client' do

    it 'invokes the given command via the client' do
      Thrift::BufferedTransport.any_instance.expects(:open)
      Thrift::BufferedTransport.any_instance.expects(:close)
      Lamp::RPC::Client.any_instance.expects(:ping).once.returns('pong')
      Lamp.client 'ping', nil, 'port' => 0
    end

  end

end

describe Lamp::RPC::Client do

  let(:rand_string) { SecureRandom.uuid }
  let(:rand_port)   { Random.rand 1000  }
  subject { Lamp::RPC::Client.new 'port' => port }

  describe '#initialize' do

    it 'sets host, port' do
      c = Lamp::RPC::Client.new('host' => rand_string, 'port' => rand_port)
      c.host.should eq rand_string
      c.port.should eq rand_port
    end

    it 'sets host to default value' do
      c = Lamp::RPC::Client.new('port' => rand_port)
      c.host.should eq Lamp::HOST
    end

    it 'raises an exception if a port is not given' do
      expect { Lamp::RPC::Client.new }.to raise_exception(ArgumentError)
    end

  end

end
