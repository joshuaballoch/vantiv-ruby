module Vantiv
  module Api
    class LiveTransactionResponse < Api::Response
      RESPONSE_CODES = {
        approved: '000',
        insufficient_funds: '110',
        invalid_account_number: '301',
        expired_card: '305',
        token_not_found: '822'
      }

      LIVE_TRANSACTION_RESPONSE_NAMES = {
        auth: "authorizationResponse",
        sale: "saleResponse"
      }

      def initialize(transaction_name)
        unless @transaction_response_name = LIVE_TRANSACTION_RESPONSE_NAMES[transaction_name]
          raise "Implementation Error: Live transactions do not include #{transaction_name}"
        end
      end

      def success?
        !api_level_failure? && transaction_approved?
      end

      def failure?
        !success?
      end

      def insufficient_funds?
        response_code == RESPONSE_CODES[:insufficient_funds]
      end

      def invalid_account_number?
        response_code == RESPONSE_CODES[:invalid_account_number]
      end

      def expired_card?
        response_code == RESPONSE_CODES[:expired_card]
      end

      private

      def transaction_approved?
        response_code == RESPONSE_CODES[:approved]
      end
    end
  end
end
