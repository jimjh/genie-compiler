# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe 'DirUtils' do

  DirUtils = Lamp::Support::DirUtils

  context 'secure copy' do

    include_context 'file ops'

    before(:each) { @dir = Pathname.new Dir.mktmpdir    }
    after(:each)  { FileUtils.remove_entry_secure @dir  }

    it 'should copy files from source to destination' do

      randx = random_file @dir + 'x'
      diry  = empty_directory @dir + 'y'
      randz = random_file diry + 'z'

      destination = Pathname.new Dir.mktmpdir
      DirUtils.copy_secure @dir, destination, %w(x y y/z)

      (destination+'x').should be_file
      IO.read(destination+'x').should eq randx

      (destination+'y').should be_directory
      IO.read(destination+'y'+'z').should eq randz

      destination.rmtree

    end

    it 'should ignore suspicious files' do

      randx = random_file @dir + 'x'

      destination = Pathname.new Dir.mktmpdir
      DirUtils.copy_secure @dir, destination,
        %w(x .. / . ./.. /.. ../..// // /// .///)

      (destination+'x').should be_file
      IO.read(destination+'x').should eq randx

      files = destination.entries.reject { |path| %w(. ..).include? path.to_s }
      files.size.should be(1)

      destination.rmtree

    end

  end

  context 'descends_from?' do

    it 'should reject the actual directory' do
      base = Pathname.new '/a/b/c'
      DirUtils.descends_from?(base, base + '.').should be_false
    end

    it 'should reject double dots' do
      base = Pathname.new '/a/b/c'
      DirUtils.descends_from?(base, base + '..').should be_false
    end

    it 'should accept descendants' do
      base = Pathname.new '/a/b/c'
      DirUtils.descends_from?(base, base + 'd').should be_true
    end

  end

end
