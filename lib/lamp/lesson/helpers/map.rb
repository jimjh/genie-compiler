module Lamp
  module Helpers
    module Map

      def map(*attrs, opts)
        sym = opts[:to]
        raise ArgumentError, 'You need to give :to as option to map' unless sym
        attrs.each { |attr| define_method(attr) { public_send(:sym)[attr] } }
      end

    end
  end
end
