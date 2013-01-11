# ~*~ encoding: utf-8 ~*~
require 'active_support/core_ext/hash'

require 'lamp/constants'
require 'lamp/logger'
require 'lamp/support'
require 'lamp/actions'

# Lamp a.k.a Genie Worker is responsible for compiling lesson sources. When the
# Lamp module is first loaded, invoke {#configure!} to read configuration
# options from {CONFIG_FILE}.
module Lamp
  include Actions
  extend self

  attr_reader     :logger

  # @return [Support::Settings] lamp's settings singleton
  def settings
    Support::Settings
  end

  # Loads configuration options from +file+. This is not thread-safe, and
  # should only be called at the beginning.
  # @param [String|Hash] arg           path to configuration file, or hash
  #                                    containing options
  # @return [void]
  def configure!(arg=CONFIG_FILE)
    case arg
    when String
      check_file     arg
      settings.load! arg
    else settings.load! arg
    end
    reset_logger
    Lesson.prepare_directories
  end

  # Creates a new logger using the configuration options from {#settings}. This
  # is not thread-safe, and should only be called at the beginning.
  # @return [void]
  def reset_logger
    @logger = Logger.new settings.log_output
  end

  settings.defaults_to DEFAULTS
  reset_logger

end

require 'lamp/lesson'
