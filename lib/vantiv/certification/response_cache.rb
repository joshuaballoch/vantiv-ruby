module Vantiv
  module Certification
    class ResponseCache
      def initialize
        @responses = {}
      end

      def push(cert_name, response)
        responses[cert_name] = response
      end

      def access_value(values_tree)
        cert_name = values_tree.shift
        response_body = responses[cert_name].body

        get_value(response_body, values_tree)
      end

      private

      attr_reader :responses

      def get_value(source, keys)
        keys.any? ? get_value(source[keys.shift], keys) : source
      end
    end

  end
end
