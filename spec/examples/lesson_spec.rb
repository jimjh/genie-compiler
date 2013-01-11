# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe Lamp::Lesson do

  describe '::prepare_directories' do

    def dir_at(name)
      Lamp.settings.root + File::SEPARATOR + name
    end

    it 'created `compiled` with public permissions' do
      dir_at('compiled').should have_mode Lamp::PERMISSIONS[:public_dir]
    end

    it 'created `lock` with private permissions' do
      dir_at('lock').should     have_mode Lamp::PERMISSIONS[:private_dir]
    end

    it 'created `source` with private permissions' do
      dir_at('source').should   have_mode Lamp::PERMISSIONS[:private_dir]
    end

    it 'created `solution` with shared permissions' do
      dir_at('solution').should have_mode Lamp::PERMISSIONS[:shared_dir]
    end

  end

end
