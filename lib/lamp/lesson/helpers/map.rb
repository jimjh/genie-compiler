module Lamp
  module Helpers
    module Map

      def map(*attrs, opts)
        v = opts[:to]
        raise ArgumentError, 'You need to give :to as option to map' unless v
        attrs.each do |attr|
          define_method(attr) { instance_variable_get("@#{v}")[attr] }
        end
      end

    end
  end
end
