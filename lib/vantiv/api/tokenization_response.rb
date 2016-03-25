module Vantiv
  module Api
    class TokenizationResponse < Api::Response
      ResponseCodes = {
        account_successfully_registered: "801",
        account_already_registered: "802",
        credit_card_number_invalid: "820",
        merchant_not_authorized_for_tokens: "821",
        token_not_found: "822",
        token_invalid: "823",
        invalid_paypage_registration_id: "877",
        expired_paypage_registration_id: "878",
        generic_token_registration_error: "898",
        generic_token_use_error: "899"
      }

      def success?
        !api_level_failure? && tokenization_successful?
      end

      def failure?
        !success?
      end

      def payment_account_id
        success? ? litle_transaction_response["PaymentAccountID"] : nil
      end

      private

      def tokenization_successful?
        response_code == ResponseCodes[:account_successfully_registered] ||
          response_code == ResponseCodes[:account_already_registered]
      end

      def transaction_response_name
        "registerTokenResponse"
      end
    end
  end
end
