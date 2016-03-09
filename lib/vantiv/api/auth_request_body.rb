module Vantiv
  module Api
    class AuthRequestBody
      def self.generate(amount:, payment_account_id:, customer_id:, order_id:)
        new(
          amount: amount,
          payment_account_id: payment_account_id,
          customer_id: customer_id,
          order_id: order_id
        ).to_hash
      end

      attr_reader :amount, :payment_account_id, :customer_id, :order_id

      def initialize(amount:, payment_account_id:, customer_id:, order_id:)
        @amount = amount
        @payment_account_id = payment_account_id
        @customer_id = customer_id
        @order_id = order_id
      end

      def to_hash
        {
          "Transaction" => {
            "ReferenceNumber" => order_id,
            "TransactionAmount" => '%.2f' % (amount / 100.0),
            "OrderSource" => get_order_source,
            "CustomerID" => customer_id,
            "PartialApprovedFlag" => false
          },
          "PaymentAccount" => {
            "PaymentAccountID" => payment_account_id
          }
        }
      end

      def get_order_source
        raise "Missing Vantiv Config: order_source" unless Vantiv.order_source
        Vantiv.order_source
      end
    end
  end
end
