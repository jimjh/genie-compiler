# ~*~ encoding: utf-8 ~*~
require 'lamp'
require 'lamp/lesson'
require 'rspec/core/shared_context'

module Test

  module GlobalContext

    extend RSpec::Core::SharedContext

    let(:output) { OUTPUT.flush; OUTPUT.string }
    before(:all) { Lamp::Lesson.prepare_directories }

  end

end
