# ~*~ encoding: utf-8 ~*~
require 'lamp/constants'
require 'active_support/core_ext/hash'

require 'lamp/support'

# Lamp a.k.a Genie Worker is responsible for compiling lesson sources. When
# the Lamp module is first loaded, it will read configuration options from
# {CONFIG_FILE}.
module Lamp
  extend Support::Logger

  # @return [Support::Settings] lamp's settings singleton
  def self.settings
    Support::Settings
  end

  # Loads configuration options from +file+.
  # @param [String] file          path to configuration file
  # @return [Void]
  def self.configure!(file=CONFIG_FILE)
    settings.defaults = DEFAULTS
    if File.exist? CONFIG_FILE then settings.load! CONFIG_FILE
    else puts "Unable to find configuration file at #{CONFIG_FILE}"
    end
  end

  configure!

end

require 'lamp/lesson'
