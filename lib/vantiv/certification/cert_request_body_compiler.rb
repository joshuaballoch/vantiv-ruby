module Vantiv
  module Certification
    class CertRequestBodyCompiler
      attr_accessor :matchers

      def initialize(*matchers)
        @matchers = matchers
      end

      def compile(hash)
        dup = {}
        hash.each do |key, value|
          if value.is_a?(Hash)
            dup[key] = compile(value)
          else
            dup[key] = compile_value(value)
          end
        end
        dup
      end

      private

      def compile_value(value)
        matchers.each do |matcher|
          if matches = matcher[:regex].match(value)
            matches = matches.to_a
            matches.shift
            matches.each do |match|
              value = matcher[:fetcher].call(value, match)
            end
          end
        end
        value
      end
    end
  end
end
