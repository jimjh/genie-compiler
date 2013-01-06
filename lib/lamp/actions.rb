# ~*~ encoding: utf-8 ~*~
require 'lamp/actions/file_actions'
require 'lamp/actions/directory_actions'

module Lamp

  # lamp-actions module contains reusable actions for consistent side effects and
  # logging.
  module Actions

    extend self

    def to_path(s)
      s.is_a?(Pathname) ? s : Pathname.new(s)
    end

  end

end
