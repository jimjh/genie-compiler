# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe Lamp::Lesson do

  describe '::compile' do

    context 'given a lesson source' do

      include_context 'lesson repo'
      let(:name) { SecureRandom.uuid }

      before(:each) { Lamp::Lesson.clone_from url, name }
      after(:each)  { Lamp::Lesson.rm name }
      let(:src)     { Pathname.new Lamp::Lesson.source_path   name }
      let(:dest)    { Pathname.new Lamp::Lesson.compiled_path name }
      def compile; Lamp::Lesson.compile name; end

      context 'and an existing output directory' do

        before :each do
          empty_directory dest
          @rand = random_file dest + Aladdin::Config::FILE
        end

        it 'overwrites the output directory' do
          compile
          IO.read(dest + Aladdin::Config::FILE).should_not eql @rand
        end

      end

      context 'and some static assets' do

        before :each do

          empty_directory src + 'img'
          @rand = random_file src + 'img' + 'x'
          IO.write src + Aladdin::Config::FILE, '{"static_paths": ["img"]}'

          random_file src + 'x'
          random_file src + 'y'
          empty_directory src + 'z'
          random_file src + 'z' + 'w'
          commit_all

        end

        it 'creates an output directory with public permissions' do
          compile
          dest.should have_mode Lamp::PERMISSIONS[:public_dir]
        end

        it 'creates static directories with public permissions' do
          compile
          (dest + 'img').should have_mode Lamp::PERMISSIONS[:public_dir]
        end

        it 'creates files with public permissions' do
          compile
          (dest + 'img' + 'x').should have_mode Lamp::PERMISSIONS[:public_file]
        end

        it 'copies static assets to target directory' do
          compile
          IO.read(dest + 'img' + 'x').should eql @rand
        end

        it 'does not copy anything else' do
          compile
          (dest + 'x').should_not be_exist
          (dest + 'y').should_not be_exist
          (dest + 'z').should_not be_exist
          (dest + 'z' + 'w').should_not be_exist
        end

      end

      context 'and a few markdown sources' do

        before :each do
          @rand_x = random_file(src + 'x.md')  { |r| "_#{r}_" }
          @rand_y = random_file(src + 'y.md')  { |r| "`#{r}`" }
          commit_all
        end

        let(:x) { (dest + 'x').sub_ext Lamp::Lesson::EXT }
        let(:y) { (dest + 'y').sub_ext Lamp::Lesson::EXT }

        it 'renders all markdown sources into html' do
          compile
          x.should be_file
          y.should be_file
          IO.read(x).should match "<em>#{@rand_x}</em>"
          IO.read(y).should match "<code>#{@rand_y}</code>"
        end

        it 'creates html files with public permissions' do
          compile
          x.should have_mode(Lamp::PERMISSIONS[:public_file])
          y.should have_mode(Lamp::PERMISSIONS[:public_file])
        end

      end

    end

    it 'raises an error if compile is given an unsafe name' do
      expect { Lamp::Lesson.compile '../jimjh/x' }.to raise_error Lamp::Lesson::NameError
    end

  end
end
