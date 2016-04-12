module Vantiv
  module MockedSandbox
    class DynamicResponseBody
      def self.generate(body:, litle_txn_name:, mocked_payment_account_id: nil)
        new(body, litle_txn_name, mocked_payment_account_id).run
      end

      def initialize(body, litle_txn_name, mocked_payment_account_id)
        @body = body
        @litle_txn_name = litle_txn_name
        @mocked_payment_account_id = mocked_payment_account_id
      end

      def run
        litle_transaction_response["@reportGroup"] = "<%= Vantiv.default_report_group %>"
        litle_transaction_response["responseTime"] = "<%= Time.now.strftime('%FT%T') %>"
        litle_transaction_response["TransactionID"] = "<%= rand(10**17) %>"
        if litle_transaction_response["PaymentAccountID"]
          litle_transaction_response["PaymentAccountID"] = mocked_payment_account_id
        end
        if litle_transaction_response["postDate"]
          litle_transaction_response["postDate"] = "<%= Time.now.strftime('%F') %>"
        end
        dynamic_body
      end

      private

      attr_reader :body, :litle_txn_name, :mocked_payment_account_id

      def litle_transaction_response
        dynamic_body["litleOnlineResponse"][litle_txn_name]
      end

      def dynamic_body
        @dynamic_body ||= body.dup
      end
    end
  end
end
