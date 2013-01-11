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

  PERMISSIONS = {
    public_dir:   0755,
    public_file:  0644,
    private_dir:  0700,
    private_file: 0600,
    shared_dir:   0750,
    shared_file:  0640
  }

end
