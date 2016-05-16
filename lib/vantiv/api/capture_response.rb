module Vantiv
  module Api
    class CaptureResponse < Api::Response
      RESPONSE_CODES = {
        transaction_received: '001',
        # TODO: check this and other possible response codes for this txn,
        #       because currently the API _ONLY_ returns 001... :'(
        invalid_amount: '209'
      }.freeze

      def success?
        !api_level_failure? && response_code == RESPONSE_CODES[:transaction_received]
      end

      def failure?
        !success?
      end

      private

      def transaction_response_name
        "captureResponse"
      end
    end
  end
end
