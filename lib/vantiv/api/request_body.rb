module Vantiv
  module Api
    module RequestBody
      def self.for_auth_or_sale(amount:, customer_id:, order_id:, payment_account_id:)
        RequestBodyGenerator.run(
          transaction_object(
            amount: amount,
            order_id: order_id,
            customer_id: customer_id
          ),
          payment_account_object(payment_account_id: payment_account_id)
        )
      end

      def self.for_capture(transaction_id:, amount: nil)
        RequestBodyGenerator.run(
          tied_transaction_object(transaction_id: transaction_id, amount: amount)
        )
      end

      def self.for_tokenization(paypage_registration_id:)
        RequestBodyGenerator.run(
          card_object_for_tokenization(paypage_registration_id)
        )
      end

      def self.card_object_for_tokenization(paypage_registration_id)
        {
          "Card" => {
            "PaypageRegistrationID" => paypage_registration_id
          }
        }
      end

      def self.tied_transaction_object(transaction_id:, amount: nil)
        res = {
          "Transaction" => {
            "TransactionID" => transaction_id
          }
        }
        if amount
          res["Transaction"]["TransactionAmount"] = '%.2f' % (amount / 100.0)
        end
        res
      end

      def self.transaction_object(amount:, customer_id:, order_id:)
        {
          "Transaction" => {
            "ReferenceNumber" => order_id,
            "TransactionAmount" => '%.2f' % (amount / 100.0),
            "OrderSource" => Vantiv.order_source,
            "CustomerID" => customer_id,
            "PartialApprovedFlag" => false
          }
        }
      end

      def self.payment_account_object(payment_account_id:)
        {
          "PaymentAccount" => {
            "PaymentAccountID" => payment_account_id
          }
        }
      end
    end

  end
end
