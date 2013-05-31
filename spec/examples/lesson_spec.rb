# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'lamp/lesson'

describe Lamp::Lesson do

  it 'responds to various path getters (both class and instance)'
  it 'responds to public_paths'
  it 'responds to in_repo'
  it 'defaults the values to what is defined in config.rb'
  it 'responds to title, description, and static_paths'

  # already invoked by global context
  describe '::prepare_directories' do

    it 'created `compiled` with public permissions' do
      Lamp::Lesson.compiled_path.should have_mode Lamp::PERMISSIONS[:public_dir]
    end

    it 'created `lock` with private permissions' do
      Lamp::Lesson.lock_path.should     have_mode Lamp::PERMISSIONS[:private_dir]
    end

    it 'created `source` with private permissions' do
      Lamp::Lesson.source_path.should   have_mode Lamp::PERMISSIONS[:private_dir]
    end

    it 'created `solution` with shared permissions' do
      Lamp::Lesson.solution_path.should have_mode Lamp::PERMISSIONS[:shared_dir]
    end

  end

end
