module Vantiv
  module Api
    class ReturnResponse < Api::Response
      ResponseCodes = {
        transaction_received: '001'
      }

      def success?
        !api_level_failure? && response_code == ResponseCodes[:transaction_received]
      end

      def failure?
        !success?
      end

      private

      def transaction_response_name
        "creditResponse"
      end
    end
  end
end
