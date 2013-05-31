# ~*~ encoding: utf-8 ~*~
require 'logger'

module Lamp

  # Log file.
  LOG_FILE = STDOUT

  # Log level.
  LOG_LEVEL = ::Logger::INFO

  # Port number. Set to 0 for ephemeral port.
  PORT = 0

  # Host name.
  HOST = 'localhost'

  # Root directory.
  ROOT = '/tmp/genie'

  # Permissions for created files.
  PERMISSIONS = {
    public_dir:   0755,
    public_file:  0644,
    private_dir:  0700,
    private_file: 0600,
    shared_dir:   0750,
    shared_file:  0640
  }.freeze

end
