# ~*~ encoding: utf-8 ~*~
require 'yaml'
require 'active_support/core_ext/hash'

module Lamp

  module Support

    # A very simple and minimal module for handling configuration options. Use
    # {#load!} to load a file or hash.
    #
    # @example Reading a configuration value
    #   Settings.email # => @_settings[:email]
    #
    # @see http://speakmy.name/2011/05/29/simple-configuration-for-ruby-apps/
    module Settings
      extend self

      @_settings, @_defaults = {}, {}
      attr_reader   :_settings

      # Initializes (or overrides) settings with options from the given file or
      # hash. The first argument can be either:
      # - the path to a configuration file, or
      # - a hash containing the configuration options
      # @return [Hash] settings
      def load!(*args)
        case (first = args.shift)
        when nil then raise ArgumentError.new 'expected either a Hash or a String as the first argument.'
        when String then load_file! first, *args
        when Hash then load_hash! first, *args
        end
      end

      # Sets the options hash to use as defaults.
      # @param [Hash]  options
      # @return [Hash] defaults
      def defaults_to(options)
        @_defaults.deep_merge! options
      end

      private

      def load_file!(filename, options = {})
        newsets = YAML::load_file(filename).symbolize_keys
        load_hash! newsets, options
      end

      def load_hash!(hash, options = {})
        @_settings.deep_merge! hash
      end

      def method_missing(name, *args, &block)
        @_settings[name.to_sym] || @_defaults[name.to_sym] ||
          fail(NoMethodError, "Unknown configuration option: #{name}.", caller)
      end

    end

  end

end
