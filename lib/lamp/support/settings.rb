# ~*~ encoding: utf-8 ~*~

module Lamp

  module Support

    # Adapted from
    # http://speakmy.name/2011/05/29/simple-configuration-for-ruby-apps/
    module Settings
      extend self

      @_settings, @defaults = {}, {}
      attr_reader :_settings
      attr_accessor :defaults

      # This is the main point of entry - we call Settings.load! and provide
      # a name of the file to read as it's argument. We can also pass in some
      # options, but at the moment it's being used to allow per-environment
      # overrides in Rails.
      #
      # The first argument can be either:
      # - the path to a configuration file, or
      # - a hash containing the configuration options
      #
      # @return [Hash] settings
      def load!(*args)
        case (first = args.shift)
        when nil then raise ArgumentError.new "wrong number of arguments"
        when String then load_file! first, args
        when Hash then load_hash! first, args
        end
      end

      private

      def load_file!(filename, options = {})
        newsets = YAML::load_file(filename).deep_symbolize
        if options[:env] && newsets[options[:env].to_sym]
          newsets = newsets[options[:env].to_sym]
        end
        @_settings.deep_merge! newsets
      end

      def load_hash!(hash, options = {})
        @_settings.deep_merge! hash
      end

      # @example
      #   Settings.email # => @_settings[:email]
      def method_missing(name, *args, &block)
        @_settings[name.to_sym] || @defaults[name.to_sym] ||
          fail(NoMethodError, "Unknown configuration root #{name}.", caller)
      end

    end

  end

end
