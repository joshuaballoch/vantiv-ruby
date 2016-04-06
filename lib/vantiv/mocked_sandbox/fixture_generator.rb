module Vantiv
  module MockedSandbox
    class FixtureGenerator
      def self.generate_all
        TestCard.all.each do |card|
          new(card: card).run
        end
      end

      attr_reader :card

      def initialize(card:)
        @card = card
      end

      def run
        record_tokenize_by_direct_post
        if card.tokenizable?
          record_auth_capture
        end
      end

      private

      def payment_account_id
        @payment_account_id ||= get_payment_account_id
      end

      def get_payment_account_id(attempts=0)
        tokenization = Vantiv.tokenize_by_direct_post(
          card_number: card.card_number,
          expiry_month: card.expiry_month,
          expiry_year: card.expiry_year,
          cvv: card.cvv
        )
        if tokenization.success?
          tokenization.payment_account_id
        elsif attempts < 3
          attempts += 1
          get_payment_account_id(attempts)
        else
          raise "Tried and failed to get payment account id"
        end
      end

      def record_tokenize_by_direct_post
        cert_response = Vantiv.tokenize_by_direct_post(
          card_number: card.card_number,
          expiry_month: card.expiry_month,
          expiry_year: card.expiry_year,
          cvv: card.cvv
        )
        dynamic_body = make_basic_elements_dynamic(cert_response.body, "registerTokenResponse")
        dynamic_body["litleOnlineResponse"]["registerTokenResponse"]["PaymentAccountID"] = "#{card.mocked_sandbox_payment_account_id}"
        write_fixture_to_file("tokenize_by_direct_post", cert_response, dynamic_body)
      end

      def record_auth_capture
        cert_response = Vantiv.auth_capture(
          amount: 10901,
          payment_account_id: payment_account_id,
          customer_id: "not-dynamic-cust-id",
          order_id: "not-dynamic-order-id"
        )
        dynamic_body = make_basic_elements_dynamic(cert_response.body, "saleResponse")
        dynamic_body["litleOnlineResponse"]["saleResponse"]["postDate"] = "<%= Time.now.strftime('%F') %>"
        write_fixture_to_file("auth_capture", cert_response, dynamic_body)
      end

      def make_basic_elements_dynamic(body, transaction_response_name)
        body["litleOnlineResponse"][transaction_response_name]["@reportGroup"] = "<%= Vantiv.default_report_group %>"
        body["litleOnlineResponse"][transaction_response_name]["responseTime"] = "<%= Time.now.strftime('%FT%T') %>"
        body["litleOnlineResponse"][transaction_response_name]["TransactionID"] = "<%= rand(10**17) %>"
        body
      end

      def write_fixture_to_file(api_method, cert_response, dynamic_body)
        File.open("#{MockedSandbox.fixtures_directory}/#{api_method}--#{card.card_number}.json.erb", 'w') do |fixture|
          fixture << JSON.pretty_generate({
            httpok: cert_response.httpok,
            http_response_code: cert_response.http_response_code,
            response_body: dynamic_body
          })
        end
      end
    end
  end
end
