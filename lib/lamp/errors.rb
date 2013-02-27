module Lamp
  # base class for all lamp exceptions
  class Error < StandardError; end
  class Abort < Error; end
end
