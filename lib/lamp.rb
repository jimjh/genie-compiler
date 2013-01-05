# ~*~ encoding: utf-8 ~*~
require 'active_support/core_ext/hash'

require 'lamp/constants'
require 'lamp/support'

# Lamp a.k.a Genie Worker is responsible for compiling lesson sources. When
# the Lamp module is first loaded, it will read configuration options from
# {CONFIG_FILE}.
module Lamp
  extend Support::Logger
  extend self

  # @return [Support::Settings] lamp's settings singleton
  def settings
    Support::Settings
  end

  # Loads configuration options from +file+.
  # @param [String] file          path to configuration file
  # @return [Void]
  def configure!(file=CONFIG_FILE)
    if File.exist? CONFIG_FILE then settings.load! CONFIG_FILE
    else puts "Unable to find configuration file at #{CONFIG_FILE}"
    end
  end

  settings.defaults_to DEFAULTS
  module_function :settings, :configure!

end

require 'lamp/lesson'
