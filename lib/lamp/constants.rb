# ~*~ encoding: utf-8 ~*~
module Lamp

  # Base class for all Lamp exceptions.
  class Error < StandardError; end

  # Default configuration options.
  DEFAULTS = {
    root:           '/tmp/genie',
    log_output:     STDOUT
  }

  # Default path to the configuration file.
  CONFIG_FILE = '/usr/local/etc/genie/worker.yml'

end
