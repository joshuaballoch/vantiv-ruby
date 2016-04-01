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
      end

      private

      def record_tokenize_by_direct_post
        cert_response = Vantiv.tokenize_by_direct_post(
          card_number: card.card_number,
          expiry_month: card.expiry_month,
          expiry_year: card.expiry_year,
          cvv: card.cvv
        )
        dynamic_body = cert_response.body
        dynamic_body["litleOnlineResponse"]["registerTokenResponse"]["@reportGroup"] = "<%= Vantiv.default_report_group %>"
        dynamic_body["litleOnlineResponse"]["registerTokenResponse"]["responseTime"] = "<%= Time.now.strftime('%FT%T') %>"
        dynamic_body["litleOnlineResponse"]["registerTokenResponse"]["TransactionID"] = "<%= rand(10**17) %>"
        dynamic_body["litleOnlineResponse"]["registerTokenResponse"]["PaymentAccountID"] = "#{card.mocked_sandbox_payment_account_id}"
        write_fixture_to_file("tokenize_by_direct_post", cert_response, dynamic_body)
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
