# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe Lamp::Actions do

  describe '#directory' do

    before(:each) { @dst = Pathname.new Dir.mktmpdir }
    after(:each)  { FileUtils.remove_entry_secure @dst }

    shared_examples 'directory permissions' do
      it 'creates a directory with the given permissions' do
        opts ||= {}
        Lamp::Actions.directory @dst + 'x', opts.merge(mode: 0600)
        (@dst + 'x').should be_directory
        sprintf("%o", File.stat(@dst + 'x').mode).should match(/0600$/)
      end
    end

    context 'when the directory exists' do

      before(:each) do
        @rand = random_file @dst + 'xyz'
      end

      it 'does nothing' do
        Lamp::Actions.directory @dst
        IO.read(@dst + 'xyz').should eq @rand
      end

      context 'with :force' do

        let(:opts) { {force: true} }

        it 'creates an empty directory' do
          Lamp::Actions.directory @dst, opts
          (@dst + 'xyz').should_not exist
        end

        include_examples 'directory permissions'

      end

    end

    context 'when the directory does not exist' do
      it 'creates an empty directory' do
        Lamp::Actions.directory @dst + 'x'
        (@dst + 'x').should be_directory
        (@dst + 'x').entries.reject { |e| %w(. ..).include? e.to_s }.compact.size.should be_zero
      end
      include_examples 'directory permissions'
    end

    context 'when the path is a file' do
      before(:each) { random_file @dst + 'xyz' }
      it 'raises a DirectoryError' do
        expect do
          Lamp::Actions.directory @dst + 'xyz'
        end.to raise_error(Lamp::Actions::DirectoryError)
      end
    end

  end

  describe '#remove' do

    before(:each) { @dst = Pathname.new Dir.mktmpdir   }
    after(:each)  { FileUtils.remove_entry_secure @dst }

    context 'path does not exist' do
      it 'does nothing' do
        Lamp::Actions.remove '/some/path/that/does/not/exist'
      end
    end

    context 'path is a directory' do
      let(:dir) do
        empty_directory @dst + 'xyz'
        random_file @dst + 'xyz' + 'k'
        @dst + 'xyz'
      end
      it 'removes recursively' do
        dir.should be_directory
        Lamp::Actions.remove dir
        dir.should_not exist
      end
    end

    context 'path is a file' do
      let(:file) { random_file @dst + 'xyz'; @dst + 'xyz' }
      it 'removes the file' do
        Lamp::Actions.remove file
        file.should_not exist
      end
    end

  end

  describe '#copy_secure' do

    before(:each) do
      @src = Pathname.new Dir.mktmpdir
      @dst = Pathname.new Dir.mktmpdir
    end

    after(:each) do
      FileUtils.remove_entry_secure @src
      FileUtils.remove_entry_secure @dst
    end

    context 'given two random files' do

      before :each do
        @randx = random_file @src + 'x'
        diry   = empty_directory @src + 'y'
        @randz = random_file diry + 'z'
        @randx = random_file @src + 'x'
      end

      it 'copies files from source to destination' do
        Lamp::Actions.copy_secure @src, @dst, %w(x y y/z)
        (@dst+'x').should be_file
        IO.read(@dst+'x').should eq @randx
        (@dst+'y').should be_directory
        IO.read(@dst+'y'+'z').should eq @randz
      end

      it 'ignores suspicious paths' do
        Lamp::Actions.copy_secure @src, @dst, %w(x .. / . ./.. ../.. //)
        (@dst+'x').should be_file
        IO.read(@dst+'x').should eq @randx
        files = @dst.entries.reject { |path| %w(. ..).include? path.to_s }
        files.size.should eq 1
      end

    end

  end

  describe '#copy' do

    before :all do
      @src = Pathname.new Dir.mktmpdir
      @dst = Pathname.new Dir.mktmpdir
    end

    after :all do
      FileUtils.remove_entry_secure @src
      FileUtils.remove_entry_secure @dst
    end

    shared_examples 'bad destination' do
      it 'raises a DirectoryError' do
        expect do
          Lamp::Actions.copy(@src, '/some/random/path/I/hope/does/not/exist')
        end.to raise_error(Lamp::Actions::DirectoryError)
      end
    end

    context 'given a non-existent destination' do
      let(:dst) { '/some/random/path/I/hope/does/not/exist' }
      it_behaves_like 'bad destination'
    end

    context 'given a non-directory destination' do
      let(:dst) { random_file @dst + 'x'; @dst + 'x' }
      it_behaves_like 'bad destination'
    end

    context 'given a non-existent source' do
      it 'raises an error if source does not exist' do
        expect do
          Lamp::Actions.copy('/some/random/path/that/does/not/exist', @dst)
        end.to raise_error(Lamp::Actions::FileError)
      end
    end

  end

  describe '#descends_from?' do
    let(:base) { Pathname.new '/a/b/c' }
    it { should_not be_descends_from(base, base + '.') }
    it { should_not be_descends_from(base, base + '..') }
    it { should be_descends_from(base, base + 'd') }
  end

  describe '#not_directory' do
    it 'raises a DirectoryError' do
      expect do
        Lamp::Actions.not_directory(Pathname.new 'my_directory')
      end.to raise_error(Lamp::Actions::DirectoryError)
    end
  end

end
