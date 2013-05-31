# ~*~ encoding: utf-8 ~*~
require 'grit'
require 'lamp/config'
require 'lamp/git/errors'
require 'lamp/git/commands'

module Lamp
  # Contains git operations that cannot be conveniently done through Grit.
  module Git; end
end
