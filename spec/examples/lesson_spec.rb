# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'lamp/lesson'

describe Lamp::Lesson do

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
