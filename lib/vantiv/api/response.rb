module Vantiv
  module Api
    class Response
      attr_reader :raw_response, :body

      def initialize(raw_response)
        @raw_response = raw_response
        @body = JSON.parse(raw_response.body)
      end

      # Only returned by cert API?
      def request_id
        body["RequestID"]
      end

      def api_level_failure?
        raw_response.code_type != Net::HTTPOK ||
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

      def litle_response
        body["litleOnlineResponse"]
      end

      def litle_transaction_response
        litle_response[transaction_response_name]
      end

      def transaction_response_name
        raise "not implemented!"
      end
    end
  end
end
