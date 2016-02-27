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

      private

      def api_level_failure?
        raw_response.code_type != Net::HTTPOK &&
          # NOTE: this kind of sucks, but at the commit point, the DevHub
          #   Api sometimes gives 200OK when litle had a parse issue and returns
          #   'Error validating xml data...' instead of an actual error
          @body["litleOnlineResponse"]["@message"].match("[E|e]rror")
      end
    end
  end
end
