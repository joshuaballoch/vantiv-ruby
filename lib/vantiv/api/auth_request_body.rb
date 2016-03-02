module Vantiv
  module Api
    class AuthRequestBody
      attr_reader :amount, :payment_account_id, :customer_id

      def initialize(amount:, payment_account_id:, customer_id:)
        @amount = amount.to_s
        @payment_account_id = payment_account_id
        @customer_id = customer_id
      end

      def to_hash
        {
          "Transaction" => {
            "ReferenceNumber": "1", #??
            "TransactionAmount": "#{amount[0..2]}.#{amount[3..5]}",
            "OrderSource": Vantiv.order_source,
            "CustomerID": customer_id,
            "PartialApprovedFlag": false #?? what is?
          },
          "PaymentAccount": {
            "PaymentAccountID": payment_account_id
          }
        }
      end
    end
  end
end
