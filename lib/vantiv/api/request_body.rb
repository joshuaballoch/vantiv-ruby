module Vantiv
  module Api
    module RequestBody
      def self.for_auth_or_sale(amount:, customer_id:, order_id:, payment_account_id:, expiry_month:, expiry_year:)
        RequestBodyGenerator.run(
          transaction_element(
            amount: amount,
            order_id: order_id,
            customer_id: customer_id
          ),
          card_element_for_live_transactions(
            expiry_month: expiry_month,
            expiry_year: expiry_year
          ),
          payment_account_element(payment_account_id: payment_account_id)
        )
      end

      def self.for_auth_reversal(transaction_id:, amount: nil)
        RequestBodyGenerator.run(
          tied_transaction_element(transaction_id: transaction_id, amount: amount)
        )
      end

      def self.for_capture(transaction_id:, amount: nil)
        RequestBodyGenerator.run(
          tied_transaction_element(transaction_id: transaction_id, amount: amount)
        )
      end

      def self.for_credit(transaction_id:, amount: nil)
        RequestBodyGenerator.run(
          tied_transaction_element(transaction_id: transaction_id, amount: amount)
        )
      end

      def self.for_return(amount:, customer_id:, order_id:, payment_account_id:, expiry_month:, expiry_year:)
        transaction = transaction_element(
          amount: amount,
          order_id: order_id,
          customer_id: customer_id
        )
        transaction["Transaction"].delete("PartialApprovedFlag")
        RequestBodyGenerator.run(
          transaction,
          card_element_for_live_transactions(
            expiry_month: expiry_month,
            expiry_year: expiry_year
          ),
          payment_account_element(payment_account_id: payment_account_id)
        )
      end

      def self.for_tokenization(paypage_registration_id:)
        RequestBodyGenerator.run(
          card_element_for_tokenization(paypage_registration_id)
        )
      end

      def self.for_direct_post_tokenization(card_number:, expiry_month:, expiry_year:, cvv:)
        RequestBodyGenerator.run(
          {
            "Card" => {
              "AccountNumber" => card_number.to_s.gsub(/\D*/, ""),
              "ExpirationMonth" => format_expiry(expiry_month),
              "ExpirationYear" => format_expiry(expiry_year),
              "CVV" => cvv.to_s
            }
          }
        )
      end

      def self.for_void(transaction_id:)
        RequestBodyGenerator.run(tied_transaction_element(transaction_id: transaction_id))
      end

      def self.card_element_for_tokenization(paypage_registration_id)
        {
          "Card" => {
            "PaypageRegistrationID" => paypage_registration_id
          }
        }
      end

      def self.card_element_for_live_transactions(expiry_month:, expiry_year:)
        {
          "Card" => {
            "ExpirationMonth" => format_expiry(expiry_month),
            "ExpirationYear" => format_expiry(expiry_year)
          }
        }
      end

      def self.tied_transaction_element(transaction_id:, amount: nil)
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

      def self.transaction_element(amount:, customer_id:, order_id:)
        {
          "Transaction" => {
            "ReferenceNumber" => order_id.to_s,
            "TransactionAmount" => '%.2f' % (amount / 100.0),
            "OrderSource" => Vantiv.order_source,
            "CustomerID" => customer_id,
            "PartialApprovedFlag" => false
          }
        }
      end

      def self.payment_account_element(payment_account_id:)
        {
          "PaymentAccount" => {
            "PaymentAccountID" => payment_account_id
          }
        }
      end

      def self.format_expiry(raw_value)
        raw_value.to_s.reverse[0..1].reverse.rjust(2, "0")
      end
    end
  end
end
