module Vantiv
  module Api
    class SaleResponse < Api::Response
      ResponseCodes = {
        approved: '000',
        insufficient_funds: '110',
        invalid_account_number: '301',
        token_not_found: '822'
      }

      def success?
        !api_level_failure? && transaction_approved?
      end

      def failure?
        !success?
      end

      def insufficient_funds?
        response_code == ResponseCodes[:insufficient_funds]
      end

      def invalid_account_number?
        response_code == ResponseCodes[:invalid_account_number]
      end

      private

      def transaction_approved?
        response_code == ResponseCodes[:approved]
      end

      def transaction_response_name
        "saleResponse"
      end
    end
  end
end
