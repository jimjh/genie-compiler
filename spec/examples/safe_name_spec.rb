# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe 'ensure_safe_name' do

  E = Lamp::Lesson::NameError

  it 'raises an error if clone is given an unsafe name' do
    expect { Lamp::Lesson.clone_from 'x', '../jimjh/x' }.to raise_error E
  end

  it 'raises an error if compile is given an unsafe name' do
    expect { Lamp::Lesson.compile '../jimjh/x' }.to raise_error E
  end

  it 'raises an error if create is given an unsafe name' do
    expect { Lamp::Lesson.create 'x', '../jimjh/x' }.to raise_error E
  end

  it 'raises an error if remove is given an unsafe name' do
    expect { Lamp::Lesson.rm '../jimjh/x' }.to raise_error E
  end

end

