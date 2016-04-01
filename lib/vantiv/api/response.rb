module Vantiv
  module Api
    class Response
      attr_reader :httpok, :http_response_code, :body

      def load(httpok:, http_response_code:, raw_body:)
        @httpok = httpok
        @http_response_code = http_response_code
        @body = JSON.parse(raw_body)
      end

      # Only returned by cert API?
      def request_id
        body["RequestID"]
      end

      def api_level_failure?
        !httpok ||
          # NOTE: this kind of sucks, but at the commit point, the DevHub
          #   Api sometimes gives 200OK when litle had a parse issue and returns
          #   'Error validating xml data...' instead of an actual error
          @body["litleOnlineResponse"]["@message"].match(/error/i)
      end

      def message
        litle_transaction_response["message"]
      end

      def response_code
        litle_transaction_response["response"]
      end

      def transaction_id
        litle_transaction_response["TransactionID"]
      end

      private

      attr_reader :transaction_response_name

      def litle_response
        api_level_failure? ? {} : body["litleOnlineResponse"]
      end

      def litle_transaction_response
        api_level_failure? ? {} : litle_response[transaction_response_name]
      end
    end
  end
end
