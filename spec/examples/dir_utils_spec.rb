# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'securerandom'

describe 'DirUtils' do

  context 'secure copy' do

    before(:each) do
      @dir = Pathname.new Dir.mktmpdir
    end

    after(:each) do
      FileUtils.remove_entry_secure @dir
    end

    it 'should copy files from source to destination' do

      rand_text = SecureRandom.uuid
      IO.write  @dir + 'x', rand_text
      (@dir + 'y').mkdir
      IO.write @dir + 'y' + 'z', rand_text

      destination = Pathname.new Dir.mktmpdir
      Lamp::Support::DirUtils.copy_secure @dir, destination,
        ['x', 'y', 'y/z']

      (destination+'x').should be_file
      IO.read(destination+'x').should eq rand_text

      (destination+'y').should be_directory
      IO.read(destination+'y'+'z').should eq rand_text

      destination.rmtree

    end

    it 'should ignore suspicious files' do

      rand_text = SecureRandom.uuid
      IO.write  @dir + 'x', rand_text

      destination = Pathname.new Dir.mktmpdir
      Lamp::Support::DirUtils.copy_secure @dir, destination,
        ['x', '..', '/', '.', './..', '/..', '../..//']

      (destination+'x').should be_file
      IO.read(destination+'x').should eq rand_text

      files = destination.entries.reject { |path| %w(. ..).include? path.to_s }
      files.size.should be(1)

      destination.rmtree

    end

  end

end
