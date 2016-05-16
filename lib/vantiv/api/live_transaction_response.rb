module Vantiv
  module Api
    class LiveTransactionResponse < Api::Response
      RESPONSE_CODES = {
        approved: '000',
        insufficient_funds: '110',
        invalid_account_number: '301',
        pick_up_card: '303',
        expired_card: '305',
        token_not_found: '822',
        token_invalid: '823'
      }.freeze

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

      def account_updater_response
        AccountUpdaterResponse.new(litle_transaction_response["accountUpdater"]) if account_updater_present?
      end

      private
      def transaction_approved?
        response_code == RESPONSE_CODES[:approved]
      end

      def account_updater_present?
        !!litle_transaction_response["accountUpdater"]
      end
    end

    class AccountUpdaterResponse
      attr_reader :account_updater_response

      def initialize(account_updater)
        @account_updater_response = account_updater
      end

      def payment_account_id
        new_card_token_info["PaymentAccountID"]
      end

      def card_type
        new_card_token_info["Type"]
      end

      def expiry_month
        new_card_token_info["ExpirationMonth"]
      end

      def expiry_year
        new_card_token_info["ExpirationYear"]
      end

      def extended_card_response_code
        extended_card_response["code"]
      end

      def extended_card_response_message
        extended_card_response["message"]
      end

      private
      def new_card_token_info
        account_updater_response.fetch("newCardTokenInfo", {})
      end

      def extended_card_response
        account_updater_response.fetch("extendedCardResponse", {})
      end
    end
  end
end
