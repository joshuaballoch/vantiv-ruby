require 'pry'
module Vantiv
  module Api
    class AuthorizationResponse < Api::Response
      ResponseCodes = {
        # TODO: review API docs to double check this
        insufficient_funds: '110',
        invalid_account_number: '301',
        success: '000',
        token_not_found: '822'
      }
      def success?
        !failure?
      end

      def failure?
        api_level_failure? || authorization_unsuccessful?
      end

      def auth_response_code
        auth_response["response"]
      end

      def transaction_id
        auth_response["TransactionID"]
      end

      def message
        auth_response["message"]
      end

      def insufficient_funds?
        auth_response_code == ResponseCodes[:insufficient_funds]
      end

      def invalid_account_number?
        auth_response_code == ResponseCodes[:invalid_account_number]
      end

      private

      def auth_response
        body["litleOnlineResponse"]["authorizationResponse"]
      end

      def authorization_successful?
        # TODO: review API docs and update this
        auth_response_code == ResponseCodes[:success]
      end

      def authorization_unsuccessful?
        !authorization_successful?
      end
    end
  end
end
